resource "kubernetes_deployment" "tafi-router" {
  metadata {
    name = "tafi-router"

    labels {
      app = "tafi-router"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "tafi-router"
      }
    }

    template {
      metadata {
        labels {
          app = "tafi-router"
        }
      }

      spec {
        container {
          name              = "tafi-router"
          image             = "us.gcr.io/tafi-dev/tafi-router:dev"
          image_pull_policy = "Always"

          #   kubectl exec consul-0 -- printenv | grep KUBERNETES_SERVICE
        #   10.3.240.1:8500
        # kubectl describe svc consul
          env {
            name  = "CONSUL_ADDRESS"
            value = "10.10.0.12:31083"
          }

          port {
            name           = "auth"
            container_port = 8081
          }

          port {
            name           = "user"
            container_port = 8082
          }

          port {
            name           = "org"
            container_port = 8083
          }

          port {
            name           = "patient"
            container_port = 8084
          }

          port {
            name           = "log"
            container_port = 8085
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tafi-router-svc" {
  metadata {
    name = "tafi-router-svc"

    labels {
      app = "tafi-router-svc"
    }
  }

  spec {
    selector {
      app = "tafi-router-svc"
    }

    type = "LoadBalancer"

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
  }
}
