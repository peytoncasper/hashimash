output "ip" {
  value = kubernetes_service.web.load_balancer_ingress.0.ip
}