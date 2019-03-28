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
        }

        #  consul agent config
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
  }
}
