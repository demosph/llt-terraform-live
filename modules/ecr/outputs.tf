output "repository_url" {
  description = "Повний URL ECR-репозиторію"
  value       = aws_ecr_repository.container_registry.repository_url
}

output "repository_arn" {
  description = "ARN ECR-репозиторію"
  value       = aws_ecr_repository.container_registry.arn
}

output "repository_name" {
  description = "Ім'я ECR-репозиторію"
  value       = aws_ecr_repository.container_registry.name
}
