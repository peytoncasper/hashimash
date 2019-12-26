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