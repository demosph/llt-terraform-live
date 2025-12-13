#-------------Backend-----------------

output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

#-------------VPC-----------------

output "vpc_id" {
  description = "ID створеної VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Список ID публічних підмереж"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

#-------------ECR-----------------

output "ecr_repository_urls" {
  value = { for name, m in module.ecr : name => m.repository_url }
}

#-------------EKS-----------------

output "eks_cluster_endpoint" {
  description = "EKS API endpoint для підключення до кластера"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Ім'я EKS кластера"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_ca" {
  description = "Base64 cluster CA"
  value       = module.eks.eks_cluster_ca
}

output "eks_node_role_arn" {
  description = "IAM role ARN для EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

output "eks_addons" {
  description = "Встановлені EKS додатки"
  value       = module.eks.eks_addons
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}
