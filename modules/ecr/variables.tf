variable "ecr_name" {
  description = "Ім'я ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Ввімкнути автоматичне сканування образів"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Mutability тегів (MUTABLE | IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "encryption_type" {
  description = "Тип шифрування (AES256 | KMS)"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "KMS ключ для шифрування (якщо encryption_type = KMS)"
  type        = string
  default     = null
}
