locals {
  trimmed_ecr_prefix = try(trim(var.ecr_prefix, "- "), null)
  trimmed_ecr_suffix = try(trim(var.ecr_suffix, "- "), null)
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.4.0"

  for_each = try(var.ecr_config.repo_list, {})

  repository_name = replace((
    local.trimmed_ecr_prefix == null ?
    (local.trimmed_ecr_suffix == null ? "${trim(each.key, "- ")}" : "${trim(each.key, "- ")}-${local.trimmed_ecr_suffix}") :
    (local.trimmed_ecr_suffix == null ? "${local.trimmed_ecr_prefix}-${trim(each.key, "- ")}" : "${local.trimmed_ecr_prefix}-${trim(each.key, "- ")}-${local.trimmed_ecr_suffix}")
  ), "/", "-")

  repository_type = "private"

  create_lifecycle_policy = try(each.value.create_lifecycle_policy, var.ecr_config.common_options.create_lifecycle_policy, false)

  repository_read_access_arns        = try(each.value.repository_read_write_access_arns, var.ecr_config.common_options.repository_read_write_access_arns, [])
  repository_read_write_access_arns  = try(each.value.repository_read_access_arns, var.ecr_config.common_options.repository_read_access_arns, [])
  repository_lambda_read_access_arns = try(each.value.repository_lambda_read_access_arns, []) # Lambda ECR access to be done on a repo by repo basis only
  repository_policy_statements       = try(each.value.repository_policy_statements, var.ecr_config.common_options.repository_policy_statements, {})
  repository_lifecycle_policy        = try(file(each.value.repository_lifecycle_policy), file(var.ecr_config.common_options.repository_lifecycle_policy), null)

  tags = merge(var.tags, try(var.ecr_config.common_options.tags, {}), try(var.ecr_config.common_options.tags, {}), try(each.value.tags, {}))
}
