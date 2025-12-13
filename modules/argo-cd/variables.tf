variable "name" {
  description = "Argo CD Helm release name"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version (argo-helm/argo-cd)"
  type        = string
  default     = "5.46.4"
}

variable "github_user" {
  description = "GitHub username"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}