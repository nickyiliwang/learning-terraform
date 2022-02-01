# root/main.tf

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

