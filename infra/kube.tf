resource "ovh_cloud_project_kube" "hf_kube" {
  service_name = var.ovh.public_cloud_tenant
  name         = "hf-bench-cluster"
  region       = "GRA7"
}


// Spawn some control planes nodes that will handle:
// - lb nginx
// - prometheus stack + grafana
resource "ovh_cloud_project_kube_nodepool" "control_planes_nodes" {
  service_name  = ovh_cloud_project_kube.hf_kube.service_name
  kube_id       = ovh_cloud_project_kube.hf_kube.id
  name          = "control-planes-nodes"
  flavor_name   = "b2-30"
  desired_nodes = 3
  max_nodes     = 3
  min_nodes     = 3
}

// Spawn some data planes that will host the api
resource "ovh_cloud_project_kube_nodepool" "data_planes_nodes" {
  service_name  = ovh_cloud_project_kube.hf_kube.service_name
  kube_id       = ovh_cloud_project_kube.hf_kube.id
  name          = "data-planes-nodes"
  flavor_name   = "b2-30"
  desired_nodes = 3
  max_nodes     = 3
  min_nodes     = 3
}

resource "local_file" "kubeconfig" {
  content  = ovh_cloud_project_kube.hf_kube.kubeconfig
  filename = "${path.module}/kubeconfig.yaml"
}
