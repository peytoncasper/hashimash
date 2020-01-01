provider "azurerm" {
    subscription_id = var.azure_subscription_id
    version = "=1.38.0"
}

provider "google" {
  project = var.gcp_project
  credentials = file(var.gcp_service_account_path)
  region  = "us-east1"
  zone    = "us-east1-c"
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
//module "azure" {
//  source = "./modules/azure"
//  azure_consul_password = var.azure_consul_password
//}

module "gcp" {
  source = "./modules/gcp"
  google_kubernetes_engine_password = var.google_kubernetes_engine_password
}

module "consul" {
  source = "./modules/consul"
  orchestrated_complexity_cluster_id = module.gcp.google_container_cluster.id
}

module "api" {
  source = "./modules/api"
}

module "sensors" {
  source = "./modules/sensors"
  consul_instance_group = module.gcp.instance_group
}
//
//output "consul_ip_addresses" {
//  value = module.gcp.gcp_consul_server_ip_addresses
//}