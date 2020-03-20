resource "kubernetes_daemonset" "consul-agent" {
  metadata {
    name = "consul-agent"

    labels = {
      name = "consul-agent"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "consul-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "consul-agent"
        }
      }

      spec {
        #  consul agent config
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        volume {
          name = "dev1"

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
            "-server",
            "-ui",
            "-advertise=$(POD_IP)",
            "-bind=0.0.0.0",
    #        "-client=127.0.0.1",
            "-retry-join=consul",
            "-domain=cluster.local",
            "-disable-host-node-id",
            "-data-dir=/consul/data",
          ]

          volume_mount {
            name       = "dev1"
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
