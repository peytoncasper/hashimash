resource "kubernetes_pod" "api_1_0_0" {
  metadata {
    name = "api-1-0-0"
    labels = {
      app = "api-1-0-0"
    }
  }

  spec {
    container {
      image = "gcr.io/${var.google_project_id}/api:latest"
      name = "api-1-0-0"
      image_pull_policy = "Always"
      env {
        name = "version"
        value = "1.0.0"
      }
      env {
        name = "consulHost"
        value = "consul.service.gcp.consul"
      }
      port {
        name = "http"
        container_port = 80
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "api_svc_1_0_0" {
  metadata {
    name = "api-1-0-0-svc"
    annotations = {
      "consul.hashicorp.com/service-name" = "api"
      "consul.hashicorp.com/service-tags": "1.0.0"
    }
  }

  spec {
    selector = {
      app = "api-1-0-0"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_pod" "api_1_0_1" {
  metadata {
    name = "api-1-0-1"
    labels = {
      app = "api-1-0-1"
    }
  }

  spec {
    container {
      image = "gcr.io/${var.google_project_id}/api:latest"
      name = "api-1-0-1"
      image_pull_policy = "Always"
      env {
        name = "version"
        value = "1.0.1"
      }
      env {
        name = "consulHost"
        value = "consul.service.gcp.consul"
      }
      port {
        name = "http"
        container_port = 80
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "api_svc_1_0_1" {
  metadata {
    name = "api-svc-1-0-1"
    annotations = {
      "consul.hashicorp.com/service-name" = "api"
      "consul.hashicorp.com/service-tags": "1.0.1"
    }
  }

  spec {
    selector = {
      app = "api-1-0-1"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}