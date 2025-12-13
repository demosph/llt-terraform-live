data "aws_ssm_parameter" "postgres_password" {
  name             = "/apps/postgres/password"
  with_decryption  = true
}

# Підключаємо модуль k8s-external-secrets
module "k8s-external-secrets" {
  source = "../modules/k8s-external-secrets"
  providers = {
    kubernetes = kubernetes.eks
  }
}

# Підключаємо модуль PostgreSQL
module "postgres_shared" {
  source             = "../modules/postgresql"
  release_name       = "pg-shared"
  namespace          = "postgresql"
  storage_class_name = "gp3"
  storage_size       = "50Gi"

  service_monitor_enabled   = true
  service_monitor_namespace = "monitoring"

  postgres_password = data.aws_ssm_parameter.postgres_password.value

  databases = [
    "llt_auth",
    "llt_trip",
    "llt_integration"
  ]

  providers = {
    helm = helm.eks,
    kubernetes = kubernetes.eks
  }

  depends_on = [
    data.aws_ssm_parameter.postgres_password
  ]
}

# Підключаємо модуль Argo CD
module "argo_cd" {
  source        = "../modules/argo-cd"
  name          = "argo-cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
  github_user     = var.github_user
  github_pat      = var.github_pat
  github_repo_url = var.github_repo_url

  providers = {
    helm = helm.eks
  }

  depends_on = [
    module.k8s-external-secrets
  ]
}
