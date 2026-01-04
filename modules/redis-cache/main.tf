resource "helm_release" "redis" {
  name             = var.release_name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  values = [
    yamlencode({
      architecture = "standalone"

      auth = {
        enabled = false
      }

      master = {
        persistence = {
          enabled = false
        }

        resources = {
          requests = {
            cpu    = var.cpu_request
            memory = var.memory_request
          }
          limits = {
            memory = var.memory_limit
          }
        }

        service = {
          ports = {
            redis = var.redis_port
          }
        }
      }

      replica = {
        replicaCount = 0
      }
    })
  ]
}
