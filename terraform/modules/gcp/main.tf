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
  name = "orchestrated-complexity-nodepool"
  location = "us-east1-c"
  cluster = google_container_cluster.orchestrated_complexity.name
  node_count = 1

  node_config {
    preemptible = true
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
    ports    = ["80", "8600", "8500", "8300", "8301", "8302"]
  }

  allow {
    protocol = "udp"
    ports    = ["80", "8600", "8300", "8301", "8302"]
  }

  target_tags = ["orchestrated-complexity"]
}

resource "null_resource" "kubectl" {
  triggers = {
    cluster = google_container_cluster.orchestrated_complexity.id
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials --zone=${google_container_cluster.orchestrated_complexity.location} ${google_container_cluster.orchestrated_complexity.name}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/config/kube-dns.yaml"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl config get-clusters | grep ${google_container_cluster.orchestrated_complexity.name} | xargs -n1 kubectl config delete-cluster"
  }

}