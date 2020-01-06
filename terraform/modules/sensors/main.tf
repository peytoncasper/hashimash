
resource "google_compute_instance" "sensor" {
  count        = 3
  name         = "sensor-${count.index}"
  machine_type = "e2-micro"
  zone         = "us-east1-c"

  tags = ["orchestrated-complexity"]

  metadata_startup_script = <<EOF
      nohup sudo nomad agent -dev -config=/etc/nomad/nomad-server.conf > /tmp/nomad.out 2> /tmp/nomad.err &
      echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
      sleep 1
      nohup sudo consul agent \
        -server \
        -datacenter=sensor-${count.index} \
        -bootstrap-expect=1 \
        -data-dir=/var/lib/consul \
        -node=sensor-${count.index} \
        -bind=0.0.0.0 \
        -client=0.0.0.0 \
        -retry-join-wan=${var.consul_ext_ip} \
        -advertise-wan=$(curl https://ipinfo.io/ip) \
        -config-dir=/etc/consul.d > /tmp/consul.out 2> /tmp/consul.err &
      sleep 30
      consul kv put sensor/api_host api.service.gcp.consul
      consul kv put sensor/version 1.0.0
      consul kv put sensor/id ${count.index}
      consul kv put sensor/x_start 0
      consul kv put sensor/y_start 0
      consul kv put sensor/vault_host vault-default.service.gcp.consul:8200
      consul kv put sensor/vault_token root
      nomad job run /home/packer/sensor/sensor.nomad
    EOF

  boot_disk {
    initialize_params {
      image = "sensor"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }



  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
