#-------------PostgreSQL-----------------

output "postgresql_service_name" {
  value = module.postgres_shared.service_name
}

output "postgresql_connection_hint" {
  value = module.postgres_shared.connection_hint
}

#-------------Argo CD-----------------

output "argo_cd_server_service" {
  value = module.argo_cd.argo_cd_server_service
}

output "argo_cd_admin_password" {
  value = module.argo_cd.admin_password
}

#-------------Redis Cache-----------------

output "redis_service_name" {
  value = module.redis_cache.redis_service_name
}

output "redis_url" {
  value = module.redis_cache.redis_url
}
