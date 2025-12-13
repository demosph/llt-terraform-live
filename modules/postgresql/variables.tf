variable "release_name" {
  description = "Helm release name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "database"
}

variable "repository" {
  description = "Helm repo URL"
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "storage_class_name" {
  description = "StorageClass for PVC"
  type        = string
  default     = null
}

variable "storage_size" {
  description = "PVC size"
  type        = string
  default     = "20Gi"
}

variable "resources" {
  description = "Pod resources"
  type = object({
    requests = optional(object({ cpu = string, memory = string }), { cpu = "250m", memory = "512Mi" })
    limits   = optional(object({ cpu = string, memory = string }), null)
  })
  default = {}
}

variable "service_monitor_enabled" {
  description = "Create ServiceMonitor (Prometheus Operator)"
  type        = bool
  default     = false
}

variable "service_monitor_namespace" {
  description = "Namespace of Prometheus Operator (optional)"
  type        = string
  default     = null
}

variable "service_monitor_interval" {
  description = "Scrape interval"
  type        = string
  default     = "30s"
}

variable "network_policy_enabled" {
  description = "Enable NetworkPolicy"
  type        = bool
  default     = false
}

variable "databases" {
  description = "List of databases to create on first bootstrap"
  type        = list(string)
  default     = []
}

variable "postgres_password" {
  description = "Superuser password"
  type        = string
  default     = null
  sensitive   = true
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "values_override" {
  description = "Raw values merged last to override any chart setting"
  type        = any
  default     = {}
}