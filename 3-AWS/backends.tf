terraform {
  backend "remote" {
    organization = "nickyiliwang"

    workspaces {
      name = "nick-dev"
    }
  }
}