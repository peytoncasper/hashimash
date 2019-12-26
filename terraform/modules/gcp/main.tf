provider "template" {}



resource "google_container_cluster" "orchestrated_complexity" {
  name     = "orchestrated-complexity"
  location = "us-east1-c"

  remove_default_node_pool = true
  initial_node_count       = 1
  enable_legacy_abac = true
  master_auth {
    username = "kubernetes"
    password = var.google_kubernetes_engine_password

    client_certificate_config {
      issue_client_certificate = true
    }
  }

}

resource "google_container_node_pool" "orchestrated_complexity" {
  name       = "orchestrated-complexity-nodepool"
  location   = "us-east1-c"
  cluster    = google_container_cluster.orchestrated_complexity.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    tags = ["orchestrated-complexity"]
  }
}

resource "google_compute_firewall" "consul" {
  name    = "consul-firewall"
  network = "default"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8500", "8300", "8301", "8302"]
  }

  allow {
    protocol = "udp"
    ports    = ["8300", "8301", "8302"]
  }

  target_tags = ["orchestrated-complexity"]
}

resource "template_dir" "config" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.cwd}/config"

  vars = {
    cluster_name    = google_container_cluster.orchestrated_complexity.name
    endpoint        = google_container_cluster.orchestrated_complexity.endpoint
    user_name       = google_container_cluster.orchestrated_complexity.master_auth.0.username
    user_password   = google_container_cluster.orchestrated_complexity.master_auth.0.password
    cluster_ca      = google_container_cluster.orchestrated_complexity.master_auth.0.cluster_ca_certificate
    client_cert     = google_container_cluster.orchestrated_complexity.master_auth.0.client_certificate
    client_cert_key = google_container_cluster.orchestrated_complexity.master_auth.0.client_key
  }
}