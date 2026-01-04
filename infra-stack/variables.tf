variable "region" {
  description = "AWS region for deployment"
  default     = "us-east-2"
}

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default = [
    "llt-auth-service",
    "llt-trip-service",
    "llt-integration-service",
    "llt-ai-recommender",
    "llt-api-gateway"
  ]
}

variable "github_repositories" {
  description = "List of GitHub repositories allowed to push to ECR"
  type        = list(string)
  default = [
    "demosph/llt-auth-user-service",
    "BalakaMd/llt-trip-service",
    "BalakaMd/llt-integration-service",
    "BalakaMd/llt-ai-recomender",
    "demosph/llt-api-gateway"
  ]
}

variable "github_ref_patterns" {
  description = "List of GitHub ref patterns allowed for pushing to ECR"
  type        = list(string)
  default     = ["ref:refs/heads/main"]
}
