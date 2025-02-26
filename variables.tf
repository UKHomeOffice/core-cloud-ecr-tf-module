variable "ecr_prefix" {
  type        = string
  description = "This is used to provide logical separation of ECR repositories. This will most likely be the name of the tenant or team"
}

variable "ecr_config" {
  type        = any
  description = "Path to YAML file that contains ECR repositories"
}

variable "tags" {
  type    = map(string)
  default = {}
}
