provider "azurerm" {
    subscription_id = var.azure_subscription_id
    version = "=1.38.0"
}

provider "google" {
  project = var.gcp_project
  credentials = file("credentials/terraform.json")
  region  = "us-east1"
}

provider "helm" {
  # kubernetes {
  #   config_path = file("config/kubeconfig.yaml")
  # }
  kubernetes {
    host                   = module.gcp.endpoint
    username               = module.gcp.username
    password               = module.gcp.password
    insecure               = true
    config_context         = "none"
    # client_certificate     = module.gcp.client_certificate
    # client_key             = module.gcp.client_key
    # cluster_ca_certificate = module.gcp.cluster_ca_certificate
  }
}

# module "azure" {
#   source = "./modules/azure"
#   azure_consul_password = var.azure_consul_password
# }

module "gcp" {
  source = "./modules/gcp"
  google_kubernetes_engine_password = var.google_kubernetes_engine_password
}

module "k8s" {
  source = "./modules/k8s"
}