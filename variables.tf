variable "ecr_config" {
  type        = any
  description = "PAth to YAML file that contains ECR repositories"
}

variable "tags" {
  type    = map(string)
  default = {}
}
