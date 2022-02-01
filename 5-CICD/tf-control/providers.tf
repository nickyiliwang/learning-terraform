terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.13.0"
    }

    tfe = {
      source = "hashicorp/tfe"
    }
  }
}

# https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs
provider "tfe" {
  token = var.tfe_token
}