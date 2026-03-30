locals {
  trimmed_ecr_prefix = try(trim(var.ecr_prefix, "- "), null)
}

data "aws_kms_key" "this" {
  count  = var.repo_kms_key == null ? 0 : 1
  key_id = var.repo_kms_key
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "3.2.0"

  for_each = try(var.ecr_config.repo_list, {})

  repository_name = local.trimmed_ecr_prefix == null ? try(trim("${each.key}", "- "), null) : "${local.trimmed_ecr_prefix}/${trim(each.key, "- ")}"
  repository_type = "private"

  repository_encryption_type = var.repo_encryption_type
  repository_kms_key         = try((var.repo_kms_key == null ? null : data.aws_kms_key.this[0].arn), null)

  repository_read_access_arns        = try(each.value.repository_read_write_access_arns, var.ecr_config.common_options.repository_read_write_access_arns, [])
  repository_read_write_access_arns  = try(each.value.repository_read_access_arns, var.ecr_config.common_options.repository_read_access_arns, [])
  repository_lambda_read_access_arns = try(each.value.repository_lambda_read_access_arns, []) # Lambda ECR access to be done on a repo by repo basis only
  repository_policy_statements       = try(each.value.repository_policy_statements, var.ecr_config.common_options.repository_policy_statements, {})

  # Default Life Cycle settings - latest tag by default is the only mutable tag
  create_lifecycle_policy     = try(each.value.create_lifecycle_policy, var.ecr_config.common_options.create_lifecycle_policy, true)
  repository_lifecycle_policy = try(file(each.value.repository_lifecycle_policy), file(var.ecr_config.common_options.repository_lifecycle_policy), <<-EOT
  {
    "rules": [
      {
        "rulePriority": 10,
        "description": "Never expire the latest tag",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["latest"],
          "countType": "imageCountMoreThan",
          "countNumber": 9999
        },
        "action": {
          "type": "expire"
        }
      },
      {
        "rulePriority": 20,
        "description": "Expire untagged artefacts after 7 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 7
        },
        "action": {
          "type": "expire"
        }
      },
      {
        "rulePriority": 30,
        "description": "keep the latest 30 tags before archiving them",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": [""],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "transition",
          "targetStorageClass": "archive"
        }
      },
      {
        "rulePriority": 40,
        "description": "Archive artefacts that have not been pulled within 30 days",
        "selection": {
          "tagStatus": "any",
          "countType": "sinceLastPulled",
          "countUnit": "days",
          "countNumber": 30
        },
        "action": {
          "type": "transition",
          "targetStorageClass": "archive"
        }
      },
      {
        "rulePriority": 50,
        "description": "Expire tags archived for more than 365 days",
        "selection": {
          "tagStatus": "any",
          "storageClass": "archive",
          "countType": "sinceImageTransitioned",
          "countUnit": "days",
          "countNumber": 365
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
  )

  # Default Immutability settings - latest tag by default is the only mutable tag
  repository_image_tag_mutability = try(each.value.repository_image_tag_mutability, var.ecr_config.common_options.repository_image_tag_mutability, "IMMUTABLE_WITH_EXCLUSION")
  repository_image_tag_mutability_exclusion_filter = try(each.value.repository_image_tag_mutability_exclusion_filter, var.ecr_config.common_options.repository_image_tag_mutability_exclusion_filter,
    [
      {
        filter      = "latest"
        filter_type = "WILDCARD"
      }
  ])

  tags = merge(var.tags, try(var.ecr_config.common_options.tags, {}), try(var.ecr_config.common_options.tags, {}), try(each.value.tags, {}))
}
