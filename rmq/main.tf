# https://github.com/rabbitmq/rabbitmq-peer-discovery-k8s

resource "kubernetes_stateful_set" "rabbitmq" {
  # service and configmap has to be deployed before kubernetes deployment
  depends_on = ["kubernetes_service.rabbitmq-svc"]

  metadata {
    name = "rabbitmq"

    labels {
      app = "rabbitmq"
    }
  }

  spec {
    # need more than 5 servers to have enough free ports
    replicas     = 1
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
        # connect as host to access consul agent
        host_network = "true"
        dns_policy   = "ClusterFirstWithHostNet"

        # rabbitmq
        container {
          name              = "rabbitmq"
          image             = "us.gcr.io/tafi-dev/rabbitmq"
          image_pull_policy = "Always"

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
