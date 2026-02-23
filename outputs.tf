output "repo_info" {
  description = "Information on the ECR repositories"
  value = {
    for k, v in module.ecr :
    k => {
      repository_name        = v.repository_name
      repository_arn         = v.repository_arn
      repository_url         = v.repository_url
      repository_registry_id = v.repository_registry_id
    }
  }
}
