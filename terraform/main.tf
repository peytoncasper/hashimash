provider "azurerm" {
    subscription_id = var.azure_subscription_id
    version = "=1.38.0"
}

provider "google" {
  project = var.google_project_id
  credentials = file(var.gcp_service_account_path)
  region  = "us-east1"
  zone    = "us-east1-c"
}

provider "kubernetes" {
  load_config_file = false
  host                   = module.gcp.google_container_cluster.endpoint
  username               = module.gcp.google_container_cluster.master_auth.0.username
  password               = module.gcp.google_container_cluster.master_auth.0.password
  client_certificate     = base64decode(module.gcp.google_container_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(module.gcp.google_container_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(module.gcp.google_container_cluster.master_auth.0.cluster_ca_certificate)
}

module "azure" {
  source = "./modules/azure"
  azure_consul_password = var.azure_consul_password
}

module "gcp" {
  source = "./modules/gcp"
  google_kubernetes_engine_password = var.google_kubernetes_engine_password

}

module "consul" {
  source = "./modules/consul"
  kubeconfig_created = module.gcp.kubeconfig_created
}

module "api" {
  source = "./modules/api"
  google_project_id = var.google_project_id
}

module "web" {
  source = "./modules/web"
  google_project_id = var.google_project_id
}

module "sensors" {
  source = "./modules/sensors"
  consul_ext_ip = module.gcp.consul_ext_ip
}

output "web-ui" {
  value = module.web.ip
}