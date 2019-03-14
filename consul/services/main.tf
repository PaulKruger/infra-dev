resource "kubernetes_service" "consul" {
  metadata {
    name = "consul"

    labels {
      name = "consul"
    }
  }

  spec {
    type = "NodePort"

    selector {
      app = "consul"
    }

    port {
      name        = "http"
      port        = 8500
      target_port = 8500
    }

    port {
      name        = "serflan-tcp"
      protocol    = "TCP"
      port        = 8301
      target_port = 8301
    }

    port {
      name        = "serflan-udp"
      protocol    = "UDP"
      port        = 8301
      target_port = 8301
    }

    port {
      name        = "serfwan-tcp"
      protocol    = "TCP"
      port        = 8302
      target_port = 8302
    }

    port {
      name        = "serfwan-udp"
      protocol    = "UDP"
      port        = 8302
      target_port = 8302
    }

    port {
      name        = "server"
      port        = 8300
      target_port = 8300
    }

    port {
      name        = "consul-dns"
      port        = 8600
      target_port = 8600
    }
  }
}
