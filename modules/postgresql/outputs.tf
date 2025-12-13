output "release_name" {
  value = helm_release.postgresql.name
}

output "namespace" {
  value = helm_release.postgresql.namespace
}

# DNS сервісу (Bitnami: <release>-postgresql)
output "service_name" {
  value = "${helm_release.postgresql.name}-postgresql"
}

output "connection_hint" {
  value = "Use host ${helm_release.postgresql.name}-postgresql.${helm_release.postgresql.namespace}.svc.cluster.local:5432, user=postgres, db=<one_of: ${join(", ", var.databases)}>"
}