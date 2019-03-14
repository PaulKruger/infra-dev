resource "kubernetes_deployment" "tafi-router" {
  metadata {
    name = "tafi-router"

    labels {
      app    = "tafi-router"
      consul = "agent"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app    = "tafi-router"
        consul = "agent"
      }
    }

    template {
      metadata {
        labels {
          app    = "tafi-router"
          consul = "agent"
        }
      }

      spec {
        #  consul agent config
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

        # tafi router
        container {
          name              = "tafi-router"
          image             = "us.gcr.io/tafi-dev/tafi-router:dev"
          image_pull_policy = "Always"

          #   kubectl exec consul-0 -- printenv | grep KUBERNETES_SERVICE
          #   10.3.240.1:8500
          # kubectl describe svc consul
          #   env {
          #     name  = "CONSUL_ADDRESS"
          #     value = "consul"
          #   }

          port {
            name           = "auth"
            container_port = 8081
          }
          port {
            name           = "user"
            container_port = 8082
          }
          port {
            name           = "org"
            container_port = 8083
          }
          port {
            name           = "patient"
            container_port = 8084
          }
          port {
            name           = "log"
            container_port = 8085
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
      app = "tafi-router-svc"
    }

    type = "LoadBalancer"

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
