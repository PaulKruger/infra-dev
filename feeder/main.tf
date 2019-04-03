resource "kubernetes_deployment" "tafi-feeder-heavy" {
  metadata {
    name = "tafi-feeder-heavy"

    labels {
      app = "tafi-feeder-heavy"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "tafi-feeder-heavy"
      }
    }

    template {
      metadata {
        labels {
          app = "tafi-feeder-heavy"
        }
      }

      spec {
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        # tafi router
        container {
          name              = "tafi-feeder-heavy"
          image             = "us.gcr.io/tafi-dev/feeder-heavy:dev"
          image_pull_policy = "Always"
        }
      }
    }
  }
}

resource "kubernetes_deployment" "tafi-feeder-postgres" {
  metadata {
    name = "tafi-feeder-postgres"

    labels {
      app = "tafi-feeder-postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "tafi-feeder-postgres"
      }
    }

    template {
      metadata {
        labels {
          app = "tafi-feeder-postgres"
        }
      }

      spec {
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        # tafi router
        container {
          name              = "tafi-feeder-postgres"
          image             = "us.gcr.io/tafi-dev/feeder-postgres:dev"
          image_pull_policy = "Always"
        }
      }
    }
  }
}