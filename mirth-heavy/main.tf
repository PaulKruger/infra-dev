resource "kubernetes_deployment" "mirth-heavy" {
  metadata {
    name = "mirth-heavy"

    labels {
      app = "mirth-heavy"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "mirth-heavy"
      }
    }

    template {
      metadata {
        labels {
          app = "mirth-heavy"
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
          name              = "mirth-heavy"
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

          # inbound
          port {
            container_port = 9600
            host_port      = 9600
          }

          # channel1
          port {
            container_port = 9601
            host_port      = 9601
          }

          # channel2
          port {
            container_port = 9602
            host_port      = 9602
          }

          # channel3
          port {
            container_port = 9603
            host_port      = 9603
          }

          # channel4
          port {
            container_port = 9604
            host_port      = 9604
          }

          # channel5
          port {
            container_port = 9605
            host_port      = 9605
          }

          # channel6
          port {
            container_port = 9606
            host_port      = 9606
          }

          # channel7
          port {
            container_port = 9607
            host_port      = 9607
          }

          # channel8
          port {
            container_port = 9608
            host_port      = 9608
          }

          # channel9
          port {
            container_port = 9609
            host_port      = 9609
          }

          # channel10
          port {
            container_port = 9610
            host_port      = 9610
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
        #           "consul services register -name=mirth-heavy -port=8080 -port=8443 -port=9600",
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

resource "kubernetes_service" "mirth-heavy-svc" {
  metadata {
    name = "mirth-heavy-svc"

    labels {
      app = "mirth-heavy-svc"
    }
  }

  spec {
    selector {
      app = "mirth-heavy"
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

    # inbound
    port {
      name        = "inbound"
      port        = 9600
      target_port = 9600
    }

    # channel1
    port {
      name        = "channel1"
      port        = 9601
      target_port = 9601
    }

    # channel2
    port {
      name        = "channel2"
      port        = 9602
      target_port = 9602
    }

    # channel3
    port {
      name        = "channel3"
      port        = 9603
      target_port = 9603
    }

    # channel4
    port {
      name        = "channel4"
      port        = 9604
      target_port = 9604
    }

    # channel5
    port {
      name        = "channel5"
      port        = 9605
      target_port = 9605
    }

    # channel6
    port {
      name        = "channel6"
      port        = 9606
      target_port = 9606
    }

    # channel7
    port {
      name        = "channel7"
      port        = 9607
      target_port = 9607
    }

    # channel8
    port {
      name        = "channel8"
      port        = 9608
      target_port = 9608
    }

    # channel9
    port {
      name        = "channel9"
      port        = 9609
      target_port = 9609
    }

    # channel10
    port {
      name        = "channel10"
      port        = 9610
      target_port = 9610
    }
  }
}
