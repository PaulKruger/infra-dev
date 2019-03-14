resource "kubernetes_deployment" "drone-server" {
  metadata {
    name = "drone-server"

    labels {
      app = "drone-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "drone-server"
      }
    }

    template {
      metadata {
        labels {
          app = "drone-server"
        }
      }

      spec {
        container {
          name              = "drone-server"
          image             = "drone/drone:0.7"
          image_pull_policy = "Always"

          env {
            name  = "DRONE_HOST"
            value = "dronedev.tafi.io"
          }

          env {
            name  = "DRONE_OPEN"
            value = true
          }

          env {
            name  = "DRONE_ORG"
            value = "tafiinc"
          }

          env {
            name  = "DRONE_GITHUB"
            value = true
          }

          env {
            name  = "DRONE_GITHUB_CLIENT"
            value = "e8f727a957e5c8dbad27"
          }

          env {
            name  = "DRONE_GITHUB_SECRET"
            value = "3f1ed96e8936cff11afaa67a4486cc6c431ce7b7"
          }

          env {
            name  = "DRONE_SECRET"
            value = "693c6c368dcce771f2b5e88ac57f1461"
          }

          volume_mount {
            mount_path = "/var/lib/drone"
            name       = "drone-lib"
          }
        }

        volume {
          name = "drone-lib"

          host_path {
            path = "/var/lib/drone"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "drone-server-svc" {
  metadata {
    name = "drone-server"

    labels {
      app = "drone-server"
    }
  }

  spec {
    selector {
      app = "drone-server"
    }

    type = "LoadBalancer"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8000
    }
  }
}

resource "kubernetes_deployment" "drone-agent" {
  metadata {
    name = "drone-agent"

    labels {
      app = "drone-agent"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "drone-agent"
      }
    }

    template {
      metadata {
        labels {
          app = "drone-agent"
        }
      }

      spec {
        container {
          name              = "drone-agent"
          image             = "drone/drone:0.7"
          image_pull_policy = "Always"

          command = [
            "/drone",
            "agent",
          ]

          env {
            name  = "DRONE_SERVER"
            value = "ws://35.226.127.178/ws/broker"
          }

          env {
            name  = "DRONE_SECRET"
            value = "693c6c368dcce771f2b5e88ac57f1461"
          }

          volume_mount {
            mount_path = "/var/run/docker.sock"
            name       = "docker-socket"
          }
        }

        volume {
          name = "docker-socket"

          host_path {
            path = "/var/run/docker.sock"
          }
        }
      }
    }
  }
}
