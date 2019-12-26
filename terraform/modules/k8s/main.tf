resource "kubernetes_config_map" "consul_config" {
  metadata {
    name = "consul-config"
  }

  data = {
    "config.json" = file("${path.module}/config.json")
  }

}

resource "kubernetes_persistent_volume_claim" "consul_data" {
  metadata {
    name = "consul-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }

}

resource "kubernetes_pod" "consul" {
  metadata {
    name = "consul"
  }

  spec {
    container {
      image = "consul"
      name = "consul"
      command = [
        "consul",
        "agent",
        "-bootstrap-expect=1",
        "-client=0.0.0.0",
        "-bind=0.0.0.0",
        "-config-dir=/consul/userconfig/config.json",
        "-ui",
        "-server",
        "-retry-join-wan=$(AZURE_CONSUL_IP)"
      ]
      env {
        name = "HOST_IP"
        value_from {
          field_ref {
            field_path = "status.hostIP"
          }
        }
      }
      env {
        name = "POD_IP"
        value_from {
          field_ref {
            field_path = "status.podIP"
          }
        }
      }
      env {
        name = "AZURE_CONSUL_IP"
        value = var.azure_consul_ip
      }
      port {
        name = "http"
        container_port = 8500
        host_port = 8500
        protocol = "TCP"
      }
      port {
        name = "server"
        container_port = 8300
        host_port = 8300
        protocol = "TCP"
      }
      port {
        name = "serverudp"
        container_port = 8300
        host_port = 8300
        protocol = "UDP"
      }
      port {
        name = "serfwan"
        container_port = 8302
        host_port = 8302
        protocol = "TCP"
      }

      port {
        name = "serflan"
        container_port = 8301
        host_port = 8301
        protocol = "TCP"
      }
      port {
        name = "serflanudp"
        container_port = 8301
        host_port = 8301
        protocol = "UDP"
      }

      port {
        name = "serfwanudp"
        container_port = 8302
        host_port = 8302
        protocol = "UDP"
      }
      volume_mount {
        mount_path = "/consul/userconfig"
        name = "userconfig"
        read_only = false
      }
      volume_mount {
        mount_path = "/consul/data"
        name = "consul-data"
      }
    }
    volume {
      name = "consul-data"
      persistent_volume_claim {
        claim_name = "consul-data"
      }
    }
    volume {
      name = "userconfig"
      config_map {
        name = "consul-config"
      }
    }
  }
}