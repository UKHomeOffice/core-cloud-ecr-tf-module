# core-cloud-ecr-tf-module
This module aims to provide a common pattern for deploying your AWS Elastic Container Registry (ECR) repositories on either a central AWS account or individual workload accounts. This module utilises the official TF module for ECR (https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest).

By default the ECR repository creates a READ/WRITE policy that defaults to the AWS account. You will need to specify additional Amazon Resource Numbers (ARNs) in the respective readwrite/readonly lists. Should you need need to provide access to other AWS accounts. You may also consider matching the OU (Organizational unit) instead using custom policy statements.

You may set common options and override them on a per-repository basis with an exception around Lambda Access.

Lambda ARNS must be declared in a separate list that can only be defined at a per-repository level. This adds additional permissions that allow Lambda to access ECR repositories to use as a runtime container.

ecr_prefix should be provided. This is to provide some logical separation of ECR repositories. This should typically be the name of the tenant or team.

# ECR Repository Name
To avoid compatibility issues with ArgoCD not supporting ECR "Namespaces" e.g. `/ (team1/nginx)` we will be disallowing the use of forward slashes. This module will convert these to hyphens.

This is due to the way ArgoCD handles ECR credentials for HELM and this might be re-visited when it's resolved. For now we will only be creating "flat" ECR repositories

Also, prefixes and ecr repo names cannot begin or end with hyphens '-'. These will be trimmed off

## Expected YAML config with Explanations
```
common_options: # These are common options that can be re-used by all of your ECR repositories
  create_lifecycle_policy: true # Defaults to false. If set to true you will need to specify repository_lifecycle_policy - this is done via filepath to a json file
  repository_lifecycle_policy: ./policies/example_common_repo_lifecycle_policy.json
  repository_read_write_access_arns: # These are sets of ARNs that are allowed READ WRITE access to your ECR Repo
    - arn:aws:iam::<ACCOUNT>:root
    - ...
  repository_read_access_arns: # These are sets of ARNs that are allowed READONLY access to your ECR Repos
    - arn:aws:iam::<ACCOUNT_2>:root
    - ...
  repository_policy_statements: # Custom policy statements to attach to your ECR repos, example shown below is an example to allow read only access to all AWS accounts belonging to a certain AWS organisation.
    orgID_readonly:
      sid: orgRO
      actions:
      - "ecr:GetAuthorizationToken"
      - "ecr:BatchCheckLayerAvailability"
      - "ecr:BatchGetImage"
      - "ecr:DescribeImageScanFindings"
      - "ecr:DescribeImages"
      - "ecr:DescribeRepositories"
      - "ecr:GetDownloadUrlForLayer"
      - "ecr:GetLifecyclePolicy"
      - "ecr:GetLifecyclePolicyPreview"
      - "ecr:GetRepositoryPolicy"
      - "ecr:ListImages"
      - "ecr:ListTagsForResource"
      principals:
        wildcard:
          type: "*"
          identifiers: ["*"]
      effect: Allow
      conditions:
      - orgMatch:
        test: "StringLike"
        variable: "aws:PrincipalOrgID"
        values:
        - o-<ORG-ID>
        - ...

repo_list: # This is where you will define your list of ECR repositories as keys. This can be done as `key: `or `key: ~` if there are no changes from the common options
  hello-world:
  foo-bar:
  custom-oci:
    repository_read_write_access_arns: # You can override the common options
      - arn:aws:iam::<ACCOUNT_3>:root
      - ...
    repository_read_access_arns:
      - arn:aws:iam::<ACCOUNT_4>:root
      - ...
    repository_lambda_read_access_arns: # This is where you'll list lambda arns that are allowed access to a particular ECR repos. This cannot be defined under common
      - ...
    repository_policy_statements: {} # Example to remove common repository_policy_statements if defined

```

Please see example directory for an example usage in both Terraform and Terragrunt.


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | 3.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecr_config"></a> [ecr\_config](#input\_ecr\_config) | Path to YAML file that contains ECR repositories | `any` | n/a | yes |
| <a name="input_ecr_prefix"></a> [ecr\_prefix](#input\_ecr\_prefix) | This is used to provide logical separation of ECR repositories. This will most likely be the name of the tenant or team | `string` | `null` | no |
| <a name="input_repo_encryption_type"></a> [repo\_encryption\_type](#input\_repo\_encryption\_type) | The encryption type to use for your repos. KMS or AES256 - Default is AES256 | `string` | `"AES256"` | no |
| <a name="input_repo_kms_key"></a> [repo\_kms\_key](#input\_repo\_kms\_key) | If KMS is selected you may optionally specify a CMK, leaving this blank will use the AWS default managed KMS key | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repo_info"></a> [repo\_info](#output\_repo\_info) | Information on the ECR repositories |
<!-- END_TF_DOCS -->
