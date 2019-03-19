# https://github.com/rabbitmq/rabbitmq-peer-discovery-k8s

resource "kubernetes_config_map" "rabbitmq" {
  metadata {
    name = "rabbitmq-config"
  }

  data {
    enabled_plugins = <<EOF
    [rabbitmq_management,rabbitmq_peer_discovery_k8s].
    EOF

    rabbitmq.conf = <<EOF
    cluster_formation.peer_discovery_backend  = rabbit_peer_discovery_k8s
    cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
    cluster_formation.k8s.address_type = hostname
    cluster_formation.node_cleanup.interval = 30
    cluster_formation.node_cleanup.only_log_warning = true
    cluster_partition_handling = autoheal
    queue_master_locator=min-masters
    loopback_users.guest = false
    EOF
  }
}

resource "kubernetes_stateful_set" "rabbitmq" {
  # service and configmap has to be deployed before kubernetes deployment
  depends_on = ["kubernetes_service.rabbitmq-svc", "kubernetes_service.rabbitmq-svc"]

  metadata {
    name = "rabbitmq"

    labels {
      app = "rabbitmq"
    }
  }

  spec {
    replicas     = 2
    service_name = "rabbitmq"

    selector {
      match_labels {
        app = "rabbitmq"
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }

    template {
      metadata {
        labels {
          app = "rabbitmq"
        }
      }

      spec {
        # rabbitmq config 
        volume {
          name = "rmq-config-volume"

          config_map {
            name = "rabbitmq-config"

            items {
              key  = "rabbitmq.conf"
              path = "rabbitmq.conf"
            }

            items {
              key  = "enabled_plugins"
              path = "enabled_plugins"
            }
          }
        }

        # rabbitmq
        container {
          name              = "rabbitmq"
          image             = "rabbitmq"
          image_pull_policy = "Always"

          volume_mount {
            name       = "rmq-config-volume"
            mount_path = "/etc/rabbitmq"
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = 15672
            host_port      = 15672
          }

          port {
            name           = "amqp"
            protocol       = "TCP"
            container_port = 5672
            host_port      = 5672
          }

          liveness_probe {
            exec {
              command = ["rabbitmqctl", "status"]
            }

            initial_delay_seconds = 60
            period_seconds        = 60
            timeout_seconds       = 15
          }

          readiness_probe {
            exec {
              command = ["rabbitmqctl", "status"]
            }

            initial_delay_seconds = 20
            period_seconds        = 60
            timeout_seconds       = 10
          }

          env {
            name = "MY_POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name  = "RABBITMQ_USE_LONGNAME"
            value = "true"
          }

          env {
            name  = "RABBITMQ_NODENAME"
            value = "rabbit@$(MY_POD_IP)"
          }

          env {
            name  = "K8S_SERVICE_NAME"
            value = "rabbitmq"
          }

          env {
            name  = "RABBITMQ_ERLANG_COOKIE"
            value = "ZxZqY6UWNZxISrD7+its6tQVQTvVlsOo+IbQ3Mm8elE="
          }
        }

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
            post_start {
              exec {
                command = [
                  "/bin/sh",
                  "-c",
                  "echo $ENABLED_PLUGINS_FILE; ls -la /"
                  # "consul services register -name=rmq -port=15672 -port=5672",
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

resource "kubernetes_service" "rabbitmq-svc" {
  metadata {
    name = "rabbitmq"

    labels {
      app = "rabbitmq"
    }
  }

  spec {
    selector {
      app = "rabbitmq"
    }

    type = "NodePort"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 15672
      target_port = 15672
    }

    port {
      name        = "amqp"
      protocol    = "TCP"
      port        = 5672
      target_port = 5672
    }
  }
}
