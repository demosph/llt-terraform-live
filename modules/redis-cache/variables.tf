variable "namespace" {
  type        = string
  description = "Kubernetes namespace to deploy Redis into"
  default     = "redis-cache"
}

variable "create_namespace" {
  type        = bool
  description = "Create namespace if it does not exist"
  default     = true
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "redis-cache"
}

variable "redis_port" {
  type        = number
  description = "Redis service port"
  default     = 6379
}

variable "cpu_request" {
  type    = string
  default = "50m"
}

variable "memory_request" {
  type    = string
  default = "128Mi"
}

variable "memory_limit" {
  type    = string
  default = "256Mi"
}
