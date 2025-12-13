locals {
  # Генеруємо idempotent SQL-блоки для кожної БД:
  db_blocks = [
    for db in var.databases : <<-EOT
    DO $do$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '${db}') THEN
        EXECUTE format('CREATE DATABASE %I', '${db}');
      END IF;
    END
    $do$;
    EOT
  ]

  init_sql = join("\n", local.db_blocks)

  base_values = {
    architecture = "standalone"

    primary = {
      persistence = {
        enabled      = true
        size         = var.storage_size
        storageClass = var.storage_class_name
        accessModes  = ["ReadWriteOnce"]
      }
      resources = {
        requests = var.resources.requests
        limits   = var.resources.limits
      }
      podSecurityContext = { enabled = true, fsGroup = 1001 }
      containerSecurityContext = {
        enabled                  = true
        runAsUser                = 1001
        allowPrivilegeEscalation = false
      }

      # Підхоплюємо скрипти ініціалізації з ConfigMap
      initdb = {
        scriptsConfigMap = kubernetes_config_map_v1.initdb.metadata[0].name
      }
    }

    volumePermissions = { enabled = true }

    networkPolicy = {
      enabled       = var.network_policy_enabled
      allowExternal = false
    }
  }

  auth_values = {
    auth = {
      postgresPassword = var.postgres_password
    }
  }

  values_merged = merge(local.base_values, local.auth_values, var.values_override)
}

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name        = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }
}

resource "kubernetes_config_map_v1" "initdb" {
  metadata {
    name      = "${var.release_name}-initdb"
    namespace = var.namespace
    labels    = var.labels
  }
  data = {
    "00-create-multiple-dbs.sql" = local.init_sql
  }
}

resource "helm_release" "postgresql" {
  name       = var.release_name
  repository = var.repository
  chart      = "postgresql"
  namespace  = var.namespace

  values = [yamlencode(local.values_merged)]

  wait    = true
  timeout = 600

  depends_on = [kubernetes_namespace_v1.ns, kubernetes_config_map_v1.initdb]
}