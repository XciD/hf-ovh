// NGINX
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.namespaces.nginx
  }
}

resource "helm_release" "nginx" {
  atomic     = true
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.7.1"
  timeout    = 120
  namespace  = kubernetes_namespace.nginx.metadata[0].name

  values = [
    templatefile("templates/values-nginx.yaml", {
      label         = "control-planes-nodes"
      nginx_resources                 = var.nginx_resources
      nginx_default_backend_resources = var.nginx_default_backend_resources
      ingress_class                   = "nginx"
      min_replicas                    = "1"
    })
  ]
}

data kubernetes_service nginx {
  metadata {
    name = "nginx-ingress-nginx-controller"
    namespace  = kubernetes_namespace.nginx.metadata[0].name
  }
}

resource "ovh_domain_zone_record" "dns" {
  zone      = var.ovh.zone
  subdomain = "*.${var.domain}"
  fieldtype = "A"
  ttl       = "300"
  target    = data.kubernetes_service.nginx.status.0.load_balancer.0.ingress[0].ip
}