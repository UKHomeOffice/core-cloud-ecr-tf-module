module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.3.1"

  for_each = try(var.ecr_config.repo_list, {})

  repository_name = "${var.ecr_config.tenant}/${each.key}"
  repository_type = "private"

  create_lifecycle_policy = try(each.value.create_lifecycle_policy, var.ecr_config.common_options.create_lifecycle_policy, false)

  repository_read_access_arns        = try(each.value.repository_read_write_access_arns, var.ecr_config.common_options.repository_read_write_access_arns, [])
  repository_read_write_access_arns  = try(each.value.repository_read_access_arns, var.ecr_config.common_options.repository_read_access_arns, [])
  repository_lambda_read_access_arns = try(each.value.repository_lambda_read_access_arns, []) # Lambda ECR access to be done on a repo by repo basis only
  repository_policy_statements       = try(each.value.repository_policy_statements, var.ecr_config.common_options.repository_policy_statements, {})
  repository_lifecycle_policy        = try(file(each.value.repository_lifecycle_policy), file(var.ecr_config.common_options.repository_lifecycle_policy), null)

  tags = var.tags
}
