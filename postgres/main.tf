# https://github.com/rabbitmq/rabbitmq-peer-discovery-k8s

resource "kubernetes_config_map" "postgres" {
  metadata {
    name = "postgres-config"
  }

  data {
    POSTGRES_USER     = "root"
    POSTGRES_PASSWORD = "root"
    POSTGRES_DB       = "tafi"
  }
}

resource "kubernetes_persistent_volume" "postgres-pv" {
  depends_on = ["kubernetes_config_map.postgres"]

  metadata {
    name = "postgres-pv-test2"
  }

  spec {
    storage_class_name = "manual"

    capacity {
      storage = "5Gi"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      host_path {
        path = "/mnt/tafi-postgres/test-data2"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres-pvc" {
  depends_on = ["kubernetes_persistent_volume.postgres-pv"]

  metadata {
    name = "postgres-pvc"
  }

  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]

    resources {
      requests {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  depends_on = ["kubernetes_persistent_volume.postgres-pv", "kubernetes_persistent_volume_claim.postgres-pvc"]

  metadata {
    name = "postgres"
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "postgres"
      }
    }

    template {
      metadata {
        name = "postgres"

        labels {
          app = "postgres"
        }
      }

      spec {
        # connect as host to access consul agent
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        # volume for postgres db
        volume {
          name = "postgresdb"

          persistent_volume_claim {
            claim_name = "postgres-pvc"
          }
        }

        container {
          name              = "postgres"
          image             = "us.gcr.io/tafi-dev/tafi-postgres"
          image_pull_policy = "Always"

          port {
            container_port = 5432
            host_port      = 5432
          }

          env_from {
            config_map_ref {
              name = "postgres-config"
            }
          }

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres-svc" {
  metadata {
    name = "postgres"

    labels {
      app = "postgres"
    }
  }

  spec {
    selector {
      app = "postgres"
    }

    type = "NodePort"

    port {
      port = 5432
    }
  }
}
