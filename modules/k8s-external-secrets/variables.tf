variable "region" {
  description = "AWS region for deployment"
  default     = "us-east-2"
}

variable "eso_namespace" {
  description = "Namespace for External Secrets Operator (ServiceAccount)"
  type        = string
  default     = "apps"
}

variable "eso_service_account_name" {
  description = "ServiceAccount for External Secrets Operator"
  type        = string
  default     = "external-secrets"
}
