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

          port {
            container_port = 9600
            host_port      = 9600
          }
        }

        # consul agent config
        host_network = true
        dns_policy   = "ClusterFirstWithHostNet"

        volume {
          name = "data1"

          host_path {
            path = "/tmp"
          }
        }

        # consul agent
        container {
          name  = "consul-agent"
          image = "consul:1.4.3"

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          args = [
            "agent",
            "-advertise=$(POD_IP)",
            "-bind=0.0.0.0",
            "-client=127.0.0.1",
            "-retry-join=consul",
            "-domain=cluster.local",
            "-disable-host-node-id",
            "-data-dir=/consul/data",
          ]

          volume_mount {
            name       = "data1"
            mount_path = "/consul/data"
          }

          # leave consul on exit
          lifecycle {
            post_start {
              exec {
                command = [
                  "/bin/sh",
                  "-c",
                  "consul services register -name=mirth-heavy -port=8080 -port=8443 -port=9600",
                ]
              }
            }

            pre_stop {
              exec {
                command = [
                  "/bin/sh",
                  "-c",
                  "consul leave",
                ]
              }
            }
          }

          # ports
          port {
            name           = "ui-port"
            protocol       = "TCP"
            container_port = 8500
            host_port      = 8500
          }

          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }

            requests {
              cpu    = "50m"
              memory = "100Mi"
            }
          }
        }
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
      app = "mirth-heavy-svc"
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
