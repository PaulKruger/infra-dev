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
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        # tafi router
        container {
          name              = "tafi-router"
          image             = "us.gcr.io/tafi-dev/tafi-router:dev"
          image_pull_policy = "Always"

          port {
            name           = "tafi-router"
            host_port      = 8080
            container_port = 8080
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
      app = "tafi-router"
    }

    type = "LoadBalancer"

    port {
      name        = "router"
      port        = 8080
      target_port = 8080
    }
  }
}
