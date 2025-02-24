# core-cloud-ecr-tf-module
This module aims to provide a common pattern for deploying your AWS Elastic Container Registry (ECR) repositories on either a central AWS account or individual workload accounts. This module utilises the official TF module for ECR (https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest).

By default the ECR repository creates a READ/WRITE policy that defaults to the AWS account. You will need to specify additional Amazon Resource Numbers (ARNs) in the respective readwrite/readonly lists. Should you need need to provide access to other AWS accounts. You may also consider matching the OU (Organizational unit) instead using custom policy statements.

You may set common options and override them on a per-repository basis with an exception around Lambda Access.

Lambda ARNS must be declared in a separate list that can only be defined at a per-repository level. This adds additional permissions that allow Lambda to access ECR repositories to use as a runtime container.

## Expected YAML config with Explanations
```
tenant: <TENANT NAME> #This is used as a prefix for your ECR repo. i.e. <prefix>/<repo name>
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
      resources: ["*"]
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
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | 2.3.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecr_config"></a> [ecr\_config](#input\_ecr\_config) | PAth to YAML file that contains ECR repositories | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->