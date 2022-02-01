# root/main.tf

locals {
  aws_creds = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
  }
  organization = "nickyiliwang"
}

resource "github_repository" "tf_repo" {
  name             = "tf-dev-repo"
  description      = "Networking and Compute Resources"
  auto_init        = true
  license_template = "mit"

  visibility = "private"
}

resource "github_branch_default" "default" {
  repository = github_repository.tf_repo.name
  branch     = "main"
}

resource "github_repository_file" "maintf" {
  repository          = github_repository.tf_repo.name
  branch              = "main"
  file                = "main.tf"
  content             = file("./deployments/tf-dev/main.tf")
  commit_message      = "Managed by Terraform"
  commit_author       = "nick"
  commit_email        = "nickyiliwang01@gmail.com"
  overwrite_on_create = true
}

# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs
resource "tfe_oauth_client" "tf_oauth" {
  organization     = local.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}

resource "tfe_workspace" "tf_cicd_workspace" {
  name         = github_repository.tf_repo.name
  organization = local.organization
  vcs_repo {
    identifier     = "${var.github_owner}/${github_repository.tf_repo.name}"
    oauth_token_id = tfe_oauth_client.tf_oauth.oauth_token_id
  }
}

resource "tfe_variable" "aws_creds" {
  for_each     = local.aws_creds
  key          = each.key
  value        = each.value
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.tf_cicd_workspace.id
  description  = "AWS credentials"
}