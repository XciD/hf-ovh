provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh.application_key
  application_secret = var.ovh.application_secret
  consumer_key       = var.ovh.consumer_key
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

locals {
  full_domain = "${var.domain}.${var.ovh.zone}"
}