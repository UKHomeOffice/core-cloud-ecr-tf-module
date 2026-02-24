variable "ecr_prefix" {
  type        = string
  description = "This is used to provide logical separation of ECR repositories. This will most likely be the name of the tenant or team"
  default     = null
}

variable "ecr_config" {
  type        = any
  description = "Path to YAML file that contains ECR repositories"
}

variable "repo_encryption_type" {
  type        = string
  description = "The encryption type to use for your repos. KMS or AES256 - Default is AES256"
  default     = "AES256"
}

variable "repo_kms_key" {
  type        = string
  description = "If KMS is selected you may optionally specify a CMK, leaving this blank will use the AWS default managed KMS key"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "List of tags for resources"
  default     = {}
}
