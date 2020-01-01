data "google_container_cluster" "cluster" {
  name     = "orchestrated-complexity"
  location = "us-east1-c"
  depends_on = [
    google_container_cluster.orchestrated_complexity
  ]
}

data "google_compute_instance_group" "instance_group" {
  self_link = google_container_node_pool.orchestrated_complexity.instance_group_urls[0]
}

output "instance_group" {
  value = google_container_node_pool.orchestrated_complexity.instance_group_urls[0]
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

