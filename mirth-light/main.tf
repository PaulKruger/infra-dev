resource "kubernetes_deployment" "mirth-light" {
  metadata {
    name = "mirth-light"

    labels {
      app = "mirth-light"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "mirth-light"
      }
    }

    template {
      metadata {
        labels {
          app = "mirth-light"
        }
      }

      spec {
        # connect as host to access consul agent
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        container {
          name              = "mirth-postgres"
          image             = "us.gcr.io/tafi-dev/mirth-postgres"
          image_pull_policy = "Always"

          port {
            container_port = 5432
            host_port      = 5432
          }
        }

        # mirth light configuration
        container {
          name              = "mirth-light"
          image             = "us.gcr.io/tafi-dev/mirth"
          image_pull_policy = "Always"

          port {
            container_port = 8080
            host_port      = 8080
          }

          port {
            container_port = 8443
            host_port      = 8443
          }

          port {
            container_port = 9600
            host_port      = 9600
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mirth-light-svc" {
  metadata {
    name = "mirth-light-svc"

    labels {
      app = "mirth-light-svc"
    }
  }

  spec {
    selector {
      app = "mirth-light"
    }

    type = "NodePort"

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    port {
      name        = "https"
      port        = 8443
      target_port = 8443
    }

    # sample channel
    port {
      name        = "channel1"
      port        = 9600
      target_port = 9600
    }
  }
}
