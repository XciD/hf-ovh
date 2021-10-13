// Monitoring
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = var.namespaces.prometheus
  }
}

// Generate a random user for basic auth in monitoring as we expose grafana and prometheus on the public ip
// Not the best practice, a vault suits better for password storage
// Also, another ingress controller for admin-ui may suit better
resource "random_password" "auth_password" {
  length = 30
}

resource "kubernetes_secret" "htpasswd" {
  metadata {
    name = "nginx-htpasswd"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
  }
  data = {
    "auth" = "user:${bcrypt(random_password.auth_password.result)}"
  }
}

// Prometheus Stack
resource "helm_release" "prometheus-stack" {
  depends_on = [
    ovh_cloud_project_kube_nodepool.control_planes_nodes
  ]
  atomic     = true
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "17.0.3"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  timeout    = 600
  values = [
    templatefile("templates/values-kube-prometheus-stack.yml", {
      domain        = "prometheus.${local.full_domain}"
      ingress_class               = "nginx"
      label         = "control-planes-nodes"
      retention                   = "7d"
      size                        = "2GB"
      prometheus_server_resources = var.prometheus_server_resources
      basic_auth_secret = kubernetes_secret.htpasswd.metadata[0].name
  })]
}

// Grafana stack plugged in with Prometheus
resource "helm_release" "grafana" {
  atomic     = true
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.6.4"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name

  values = [
    templatefile("templates/values-grafana.yml", {
      label         = "control-planes-nodes"
      resources     = var.grafana_resources
      ingress_class = "nginx"
      domain        = "grafana.${local.full_domain}"
      basic_auth_secret = kubernetes_secret.htpasswd.metadata[0].name
    })
  ]
}

// Auto import dashboard
resource "kubernetes_config_map" "infra_dashboard" {
  for_each = fileset("templates/", "dashboard-*.json")
  metadata {
    name      = "grafana-infra-${each.key}"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
    labels = {
      grafana_dashboard : "1"
    }
  }
  data = {
    "${each.key}.json" : file("templates/${each.key}")
  }
}

// Output the grafana admin secret
data "kubernetes_secret" "grafana" {
  depends_on = [helm_release.grafana]
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
  }
}

output "secrets" {
  value = {
    grafana_admin = data.kubernetes_secret.grafana.data
    htpasswd = random_password.auth_password.result
  }
}

