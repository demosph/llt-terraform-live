variable "region" {
  description = "AWS region for deployment"
  default     = "us-east-2"
}

variable "github_repo_url" {
  description = "GitHub repository URL for auth service"
  type        = string
  default     = "https://github.com/demosph/llt-terraform-live.git"
}

variable "github_user" {
  description = "GitHub username for auth service"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for auth service"
  type        = string
  sensitive   = true
}
