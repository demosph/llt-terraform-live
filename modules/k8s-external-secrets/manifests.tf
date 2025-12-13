# Create ClusterSecretStore
resource "kubernetes_manifest" "cluster_secret_store_ssm" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-ssm"
    }
    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = var.eso_service_account_name
                namespace = var.eso_namespace
              }
            }
          }
        }
      }
    }
  }
}

# Create ExternalSecret
resource "kubernetes_manifest" "external_secret_auth_jwt_db" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "auth-jwt-db"
      namespace = var.eso_namespace
    }
    spec = {
      refreshInterval = "1m"
      secretStoreRef = {
        name = "aws-ssm"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "auth-jwt-db"
        creationPolicy = "Owner"
        template = {
          type = "Opaque"
        }
      }
      data = [
        {
          secretKey = "POSTGRES_PASSWORD"
          remoteRef = { key = "/apps/postgres/password" }
        },
        {
          secretKey = "JWT_SECRET"
          remoteRef = { key = "/apps/jwt-secret" }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.cluster_secret_store_ssm
  ]
}