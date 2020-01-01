provider "template" {}

data "google_compute_instance_group" "instance_group" {
  self_link = var.consul_instance_group
}

data "google_compute_instance" "instances" {
  for_each = data.google_compute_instance_group.instance_group.instances
  self_link = each.value
}

data "null_data_source" "consul_ext_ips" {
  inputs = {
    values = join(",", [for instance in data.google_compute_instance.instances: instance.network_interface.0.access_config.0.nat_ip])
  }
}

resource "google_compute_instance" "sensor-1" {
  name         = "sensor-1"
  machine_type = "e2-micro"
  zone         = "us-east1-c"

  tags = ["orchestrated-complexity","sensor-1"]

  metadata_startup_script = <<EOF
      export SENSOR_VERSION=1.0.0
      export SENSOR_ID=1
      export SENSOR_API_URL=http://api.service.gcp.consul
      nohup sudo nomad agent -dev -config=/etc/nomad > /tmp/nomad.out 2> /tmp/nomad.err &
      echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
      sleep 1
      nohup sudo consul agent \
        -server \
        -datacenter=sensor-1 \
        -bootstrap-expect=1 \
        -data-dir=/var/lib/consul \
        -node=sensor-1 \
        -bind=0.0.0.0 \
        -client=0.0.0.0 \
        -retry-join-wan=${data.null_data_source.consul_ext_ips.outputs["values"]} \
        -advertise-wan=$(curl https://ipinfo.io/ip) \
        -config-dir=/etc/consul.d > /tmp/consul.out 2> /tmp/consul.err &
      sleep 5
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