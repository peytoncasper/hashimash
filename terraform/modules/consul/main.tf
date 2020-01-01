resource "null_resource" "kubectl" {
  triggers = {
    cluster = var.orchestrated_complexity_cluster_id
  }

  provisioner "local-exec" {
    command = "helm install -f helm-consul-values.yaml hashicorp ./${path.module}/consul-helm"
  }
}