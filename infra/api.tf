// API Definition
resource "kubernetes_namespace" "api" {
  metadata {
    name = var.namespaces.api
  }
}

resource "kubernetes_deployment" "api" {
  wait_for_rollout = true
  timeouts {
    create = "300s"
    update = "300s"
    delete = "60s"
  }
  metadata {
    name      = var.api_config.name
    namespace = kubernetes_namespace.api.metadata[0].name
    labels = {
      app = var.api_config.name
    }
  }

  spec {
    replicas = var.api_config.min_replicas
    selector {
      match_labels = {
        app = var.api_config.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.api_config.name
        }
      }
      spec {
        node_selector = {
          "nodepool": "data-planes-nodes"
        }
        termination_grace_period_seconds = 20
        container {
          name              = var.api_config.name
          image             = "${var.api_config.image}:${var.api_config.tag}"
          image_pull_policy = "Always"
          port {
            container_port = 5000
            name           = "http"
          }
          liveness_probe {
            tcp_socket {
              port = "5000"
            }
          }
          readiness_probe {
            tcp_socket {
              port = "5000"
            }
          }
          resources {
            limits = {
              cpu    = var.api_resources.limits.cpu
              memory = var.api_resources.limits.memory
            }
            requests = {
              cpu    = var.api_resources.requests.cpu
              memory = var.api_resources.requests.memory
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = var.api_config.name
    namespace = kubernetes_namespace.api.metadata[0].name
    labels = {
      app = var.api_config.name
    }
  }
  spec {
    port {
      port        = 80
      name        = "http"
      target_port = "http"
    }

    selector = {
      app : var.api_config.name
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "rcp" {
  metadata {
    name      = var.api_config.name
    namespace = kubernetes_namespace.api.metadata[0].name
    labels = {
      app = var.api_config.name
    }
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" : "600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" : "600"
    }
  }

  spec {
    rule {
      host = "api.${local.full_domain}"
      http {
        path {
          backend {
            service_name = kubernetes_service.api.metadata[0].name
            service_port = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "api" {
  metadata {
    name      = var.api_config.name
    namespace = kubernetes_namespace.api.metadata[0].name
    labels = {
      app = var.api_config.name
    }
  }
  spec {
    min_replicas = var.api_config.min_replicas
    max_replicas = var.api_config.max_replicas
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = var.api_config.name
    }
    target_cpu_utilization_percentage = 50
  }
}

