//
// Consul Helm Chart Installation
// This utilizes local-exec to install the a modified version of HashiCorp's Consul Helm Chart
// onto the provide GKE cluster. As a result, this requires helm to be installed locally and
// the git submodule to be cloned.
//

resource "null_resource" "kubectl" {
  triggers = {
    cluster = var.kubeconfig_created
  }

  provisioner "local-exec" {
    command = "helm install -f helm-consul-values.yaml hashicorp ./${path.module}/consul-helm-multi-dc"
  }
}