output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_ca" {
  description = "Base64 cluster CA"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}

output "eks_addons" {
  description = "Installed EKS addons"
  value = {
    ebs_csi_driver     = try(aws_eks_addon.ebs_csi_driver.addon_version, null)
    metrics_server     = try(aws_eks_addon.metrics_server.addon_version, null)
  }
}

output "eso_irsa_role_arn" {
  description = "IAM Role ARN for IRSA (External Secrets Operator)"
  value       = aws_iam_role.eso_irsa_role.arn
}
