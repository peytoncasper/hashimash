//
// Google Kubernetes Engine Config
// The segments of code below are related to extracting the necessary kubeconfig values
// and exposing them as outputs so that they can be passed along to the Kubernetes Terraform Provider.
//

data "google_container_cluster" "cluster" {
  name     = "orchestrated-complexity"
  location = "us-east1-c"
  depends_on = [
    google_container_cluster.orchestrated_complexity
  ]
}

output "google_container_cluster" {
  value = google_container_cluster.orchestrated_complexity
}

output "endpoint" {
  value = data.google_container_cluster.cluster.endpoint
}

output "username" {
  value = data.google_container_cluster.cluster.master_auth.0.username
  depends_on = [
    google_container_cluster.orchestrated_complexity
  ]
}

output "password" {
  value = data.google_container_cluster.cluster.master_auth[0].password
}

output "client_certificate" {
  value = data.google_container_cluster.cluster.master_auth.0.client_certificate
}

output "client_key" {
  value = data.google_container_cluster.cluster.master_auth.0.client_key
}

output "cluster_ca_certificate" {
  value = data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
  depends_on = [
      data.google_container_cluster.cluster.master_auth
  ]
}

//
// Consul Public Ip
// Due to the static node count for this example, we're able to pull the specific node pool
// Parse its interior instances to a list and extract the first VM instance which is then resolved
// and its nat_ip value its accessed and passed as an output
//

data "google_compute_instance_group" "k8s_instance_group" {
  self_link = google_container_node_pool.orchestrated_complexity.instance_group_urls[0]
}

data "google_compute_instance" consul_vm {
  self_link = element(tolist(data.google_compute_instance_group.k8s_instance_group.instances), 0)
}

output "consul_ext_ip" {
  value = data.google_compute_instance.consul_vm.network_interface.0.access_config.0.nat_ip
}

output "kubeconfig_created" {
  value = null_resource.kubectl.id
}