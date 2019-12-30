resource "kubernetes_config_map" "consul_config" {
  metadata {
    name = "consul-config"
  }

  data = {
    "config.json" = file("${path.module}/config.json"),
    "services.json" = file("${path.module}/services.json")
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
    labels = {
      app = "consul"
    }
  }

  spec {
    container {
      image = "consul"
      name = "consul"
      command = [
        "/bin/sh",
        "-ec",
        "PUBLIC_IP=$(curl https://ipinfo.io/ip); exec /bin/consul agent -bootstrap-expect=1 -bind=0.0.0.0 -advertise=$PUBLIC_IP -advertise-wan=$PUBLIC_IP -config-dir=/consul/userconfig -retry-join-wan=$(AZURE_CONSUL_IP) -server -ui",
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
        name = "dns-tcp"
        container_port = 8600
        host_port = 8600
        protocol = "TCP"
      }
      port {
        name = "dns-udp"
        container_port = 8600
        host_port = 8600
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

resource "kubernetes_service" "consul_svc" {
  metadata {
    name = "consul"
  }

  spec {
    selector = {
      app = "consul"
    }
    port {
      name = "dns-tcp"
      port        = 8600
      target_port = 8600
      protocol = "TCP"
    }
    port {
      name = "dns-udp"
      port        = 8600
      target_port = 8600
      protocol = "UDP"
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_service" "consul_dns" {
  metadata {
    name = "consul-dns"
  }

  spec {
    selector = {
      app = "consul"
    }
    port {
      name = "dns-tcp"
      port        = 53
      target_port = "dns-tcp"
      protocol = "TCP"
    }
    port {
      name = "dns-udp"
      port        = 53
      target_port = "dns-udp"
      protocol = "UDP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_config_map" "kube_dns" {
  metadata {
    name = "kube-dns"
    namespace = "kube-system"
    labels = {
      "addonmanager.kubernetes.io/mode" = "EnsureExists"
    }
  }

  data = {
    "stubDomains" = format("{\"consul\": [\"%s\"]}", "consul-dns.default.svc.cluster.local")
  }
}


resource "kubernetes_pod" "complexity_inc_web" {
  metadata {
    name = "complexity-inc-web"
  }

  spec {
    container {
      image = "gcr.io/complexity-inc/complexity-inc-web:1.0.0"
      name = "complexity-inc-web"
    }
  }
}

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
//
//resource "kubernetes_service" "complexity_inc_web" {
//  metadata {
//    name = "complexity-inc-web-svc"
//  }
//
//  spec {
//    selector = {
//      app = "complexity-inc-web"
//    }
//    port {
//      port        = 80
//      target_port = 80
//    }
//    type = "LoadBalancer"
//  }
//}