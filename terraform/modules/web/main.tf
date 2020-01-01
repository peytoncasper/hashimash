resource "kubernetes_pod" "complexity_inc_web" {
  metadata {
    name = "complexity-inc-web"
  }

  spec {
    container {
      image = "gcr.io/complexity-inc/complexity-inc-web:1.0.0"
      name = "complexity-inc-web"
    }
  }
}


//
//resource "kubernetes_service" "complexity_inc_web" {
//  metadata {
//    name = "complexity-inc-web-svc"
//  }
//
//  spec {
//    selector = {
//      app = "complexity-inc-web"
//    }
//    port {
//      port        = 80
//      target_port = 80
//    }
//    type = "LoadBalancer"
//  }
