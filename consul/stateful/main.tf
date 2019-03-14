resource "kubernetes_stateful_set" "consul" {
  metadata {
    name = "consul"

    labels {
      name = "consul"
    }
  }

  spec {
    selector {
      match_labels {
        app = "consul"
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }

    replicas              = 3
    pod_management_policy = "Parallel"
    service_name          = "consul"

    template {
      metadata {
        labels {
          app = "consul"
        }
      }

      spec {
        container {
          name = "consul"

          # consul:1.4.3 is the latest image
          image = "consul:1.4.3"

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name = "NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          # consul agent -server -bootstrap-expect 3 -ui -disable-host-node-id -client 0.0.0.0
          args = [
            "agent",
            "-server",
            "-ui",
            "-bootstrap-expect=3",
            "-retry-join=consul",
            "-retry-join=consul-1.default.svc.cluster.local",
            "-retry-join=consul-2.consul.default.svc.cluster.local",
            "-domain=cluster.local",
            "-disable-host-node-id",
            "-bind=0.0.0.0",
            "-advertise=$(POD_IP)",
            "-data-dir=/consul/data",
          ]

          volume_mount {
            name       = "data1"
            mount_path = "/consul/data"
          }

          # leave consul on exit
          lifecycle {
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
            container_port = 8500
          }

          port {
            name           = "alt-port"
            container_port = 8400
          }

          port {
            name           = "udp-port"
            container_port = 53
          }

          port {
            name           = "https-port"
            container_port = 8443
          }

          port {
            name           = "http-port"
            container_port = 8080
          }

          port {
            name           = "serflan"
            container_port = 8301
          }

          port {
            name           = "serfwan"
            container_port = 8302
          }

          port {
            name           = "consul-dns"
            container_port = 8600
          }

          port {
            name           = "server"
            container_port = 8300
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data1"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests {
            storage = "5Gi"
          }
        }
      }
    }
  }
}
