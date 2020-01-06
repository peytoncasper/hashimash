resource "kubernetes_pod" "api_1_0_0" {
  metadata {
    name = "api-1-0-0"
    labels = {
      app = "api-1-0-0"
    }
    annotations = {
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
        name = "consul_host"
        value = "consul.service.gcp.consul"
      }
      env {
        name = "vault_host"
        value = "vault-default.service.gcp.consul:8200"
      }
      env {
        name = "vault_token"
        value = "root"
      }
      env {
        name = "api_token"
        value = "0z7uw5zfMIpZMp5h"
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
      "consul.hashicorp.com/service-tags" = "1.0.0"
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
        name = "consul_host"
        value = "consul.service.gcp.consul"
      }
      env {
        name = "vault_host"
        value = "vault-default.service.gcp.consul:8200"
      }
      env {
        name = "vault_token"
        value = "root"
      }
      env {
        name = "api_token"
        value = "0z7uw5zfMIpZMp5h"
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
      "consul.hashicorp.com/service-tags" = "1.0.1"
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