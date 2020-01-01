resource "kubernetes_pod" "complexity_inc_api" {
  metadata {
    name = "complexity-inc-api"
    labels = {
      app = "complexity-inc-api"
    }
  }

  spec {
    container {
      image = "gcr.io/complexity-inc/complexity-inc-api:1.0.0"
      name = "complexity-inc-api"
      env {
        name = "version"
        value = "1.0.0"
      }
      port {
        name = "http"
        container_port = 80
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "complexity_inc_api_svc" {
  metadata {
    name = "complexity-inc-api-svc"
  }

  spec {
    selector = {
      app = "complexity-inc-api"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}