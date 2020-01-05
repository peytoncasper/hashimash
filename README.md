terraform import module.k8s.kubernetes_config_map.kube_dns kube-system/kube-dns

Requirements
1. Install Docker
1. Install Helm

packer build packer/api.json
packer build packer/web.json
packer build packer/sensor.json

terraform apply -target=module.gcp terraform
terraform apply -target=module.consul terraform
terraform apply -target=module.api terraform
terraform apply -target=module.sensors