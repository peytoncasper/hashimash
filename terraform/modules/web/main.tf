resource "kubernetes_pod" "web" {
  metadata {
    name = "complexity-inc-web"
    labels = {
      app = "complexity-inc-web"
    }
  }


  spec {
    container {
      image_pull_policy = "Always"
      image = "gcr.io/${var.google_project_id}/web:latest"
      name = "web"

      env {
        name = "apiHost"
        value = "api.service.gcp.consul"
      }
      port {
        name = "http"
        container_port = 80
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "web-svc"
    annotations = {
      "consul.hashicorp.com/service-name" = "web"
      "consul.hashicorp.com/service-tags": "1.0.0"
    }
  }

  spec {
    selector = {
      app = "web"
    }
    port {
      port = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}