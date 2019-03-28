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
        }

        # consul agent config
        # host_network = true
        # dns_policy   = "ClusterFirstWithHostNet"

        # volume {
        #   name = "data1"

        #   host_path {
        #     path = "/tmp"
        #   }
        # }

        # # consul agent
        # container {
        #   name  = "consul-agent"
        #   image = "consul:1.4.3"

        #   env {
        #     name = "POD_IP"

        #     value_from {
        #       field_ref {
        #         field_path = "status.podIP"
        #       }
        #     }
        #   }

        #   args = [
        #     "agent",
        #     "-advertise=$(POD_IP)",
        #     "-bind=0.0.0.0",
        #     "-client=127.0.0.1",
        #     "-retry-join=consul",
        #     "-domain=cluster.local",
        #     "-disable-host-node-id",
        #     "-data-dir=/consul/data",
        #   ]

        #   volume_mount {
        #     name       = "data1"
        #     mount_path = "/consul/data"
        #   }

        #   # leave consul on exit
        #   lifecycle {
        #     post_start {
        #       exec {
        #         command = [
        #           "/bin/sh",
        #           "-c",
        #           "consul services register -name=postgres -port=5432",
        #         ]
        #       }
        #     }

        #     pre_stop {
        #       exec {
        #         command = [
        #           "/bin/sh",
        #           "-c",
        #           "consul leave",
        #         ]
        #       }
        #     }
        #   }

        #   # ports
        #   port {
        #     name           = "ui-port"
        #     protocol       = "TCP"
        #     container_port = 8500
        #     host_port      = 8500
        #   }

        #   resources {
        #     limits {
        #       cpu    = "100m"
        #       memory = "100Mi"
        #     }

        #     requests {
        #       cpu    = "50m"
        #       memory = "100Mi"
        #     }
        #   }
        # }
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
