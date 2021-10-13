variable "ovh" {
  type = map(string)
  default = {
    // your OVH API credentials
    application_key     = ""
    application_secret  = ""
    consumer_key        = ""
    public_cloud_tenant = ""
    zone = ""
  }
}

variable "domain" {
  type = string
  default = ""
}

variable "namespaces" {
  type = map(string)
  default = {
    "nginx" : "nginx"
    "prometheus" : "prometheus"
  }
}


variable "nginx_resources" {
  type = map(map(any))
  default = {
    "limits" : { "cpu" : "1", "memory" : "500M" }
    "requests" : { "cpu" : "1", "memory" : "500M" }
  }
}

variable "nginx_default_backend_resources" {
  type = map(map(any))
  default = {
    "limits" : { "cpu" : "250m", "memory" : "20M" }
    "requests" : { "cpu" : "100m", "memory" : "20M" }
  }
}

variable "grafana_resources" {
  default = {
    "limits" : { "cpu" : "1", "memory" : "500M" }
    "requests" : { "cpu" : "1", "memory" : "500M" }
  }
}

variable "prometheus_server_resources" {
  type = map(map(any))
  default = {
    "limits" : { "cpu" : "2", "memory" : "2G" }
    "requests" : { "cpu" : "2", "memory" : "2G" }
  }
}

variable "prometheus_node_exporter_resources" {
  type = map(map(any))
  default = {
    "limits" : { "cpu" : "500m", "memory" : "100M" }
    "requests" : { "cpu" : "100m", "memory" : "100M" }
  }
}