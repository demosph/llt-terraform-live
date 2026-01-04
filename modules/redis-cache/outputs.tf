locals {
  service_name = "${var.release_name}-master"
}

output "redis_service_name" {
  value = local.service_name
}

output "redis_host" {
  value = "${local.service_name}.${var.namespace}.svc.cluster.local"
}

output "redis_port" {
  value = var.redis_port
}

output "redis_url" {
  value = "redis://${local.service_name}.${var.namespace}.svc.cluster.local:${var.redis_port}"
}
