//
// Vault Helm Chart Installation
// This utilizes local-exec to install the HashiCorp Vault Helm chart
// onto the provide GKE cluster. As a result, this requires helm to be installed locally and
// the git submodule to be cloned.
//

resource "null_resource" "kubectl" {
  triggers = {
    cluster = var.kubeconfig_created
  }

  provisioner "local-exec" {
    command = "helm install -f helm-vault-values.yaml vault ./${path.module}/vault-helm"
  }
  provisioner "local-exec" {
    when = destroy
    command = "helm delete vault"
  }
}