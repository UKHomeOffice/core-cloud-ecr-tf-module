module "ecr_repos" {
  source = "../"

  ecr_config = yamldecode(file("./example_repos.yaml"))

  tags = {
    cost-centre = "..."
    finance-account-id = "..."
    portfolio-id = "..."
    project-id = "..."
    service-id = "..."
  }
}
