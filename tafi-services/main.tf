resource "kubernetes_deployment" "tafi-services" {
  metadata {
    name = "tafi-services"

    labels {
      app = "tafi-services"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "tafi-services"
      }
    }

    template {
      metadata {
        labels {
          app = "tafi-services"
        }
      }

      spec {
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        # tafi router
        container {
          name              = "tafi-services"
          image             = "us.gcr.io/tafi-dev/tafi-services:dev"
          image_pull_policy = "Always"

          port {
            name           = "auth"
            host_port      = 8081
            container_port = 8081
          }
          port {
            name           = "user"
            host_port      = 8082
            container_port = 8082
          }
          port {
            name           = "org"
            host_port      = 8083
            container_port = 8083
          }
          port {
            name           = "patient"
            host_port      = 8084
            container_port = 8084
          }
          port {
            name           = "log"
            host_port      = 8085
            container_port = 8085
          }

          port {
            name           = "inbound"
            host_port      = 8086
            container_port = 8086
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tafi-services-svc" {
  metadata {
    name = "tafi-services-svc"

    labels {
      app = "tafi-services-svc"
    }
  }

  spec {
    selector {
      app = "tafi-services"
    }

    type = "NodePort"

    port {
      name        = "auth"
      port        = 8081
      target_port = 8081
    }

    port {
      name        = "user"
      port        = 8082
      target_port = 8082
    }

    port {
      name        = "org"
      port        = 8083
      target_port = 8083
    }

    port {
      name        = "patient"
      port        = 8084
      target_port = 8084
    }

    port {
      name        = "log"
      port        = 8085
      target_port = 8085
    }

    port {
      name        = "inbound"
      port        = 8086
      target_port = 8086
    }
  }
}
