provider "azurerm" {
    subscription_id = var.azure_subscription_id
    version = "=1.38.0"
}

provider "google" {
  project = var.gcp_project
  credentials = file("credentials/terraform.json")
  region  = "us-east1"
}

provider "kubernetes" {
  host                   = module.gcp.google_container_cluster.endpoint
  username               = module.gcp.google_container_cluster.master_auth.0.username
  password               = module.gcp.google_container_cluster.master_auth.0.password
  client_certificate     = base64decode(module.gcp.google_container_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(module.gcp.google_container_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(module.gcp.google_container_cluster.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.gcp.google_container_cluster.endpoint
    username               = module.gcp.google_container_cluster.master_auth.0.username
    password               = module.gcp.google_container_cluster.master_auth.0.password
    config_context         = "none"
    client_certificate     = base64decode(module.gcp.google_container_cluster.master_auth.0.client_certificate)
    client_key             = base64decode(module.gcp.google_container_cluster.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(module.gcp.google_container_cluster.master_auth.0.cluster_ca_certificate)
  }
}

module "azure" {
  source = "./modules/azure"
  azure_consul_password = var.azure_consul_password
}

module "gcp" {
  source = "./modules/gcp"
  google_kubernetes_engine_password = var.google_kubernetes_engine_password
}

module "k8s" {
  source = "./modules/k8s"
  azure_consul_ip = module.azure.azure_consul_ip
}