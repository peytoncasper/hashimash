# data "helm_repository" "consul" {
#   name = "consul"
#   url  = 
# }

resource "helm_release" "example" {
  name       = "consul-server"
  repository = "stable"
  chart      = "consul"
  version    = "3.9.4"

#   values = [
#     "${file("values.yaml")}"
#   ]

  set {
    name  = "replicas"
    value = "1"
  }

#   set {
#     name  = "metrics.enabled"
#     value = "true"
#   }

#   set_string {
#     name  = "service.annotations.prometheus\\.io/port"
#     value = "9127"
#   }
}