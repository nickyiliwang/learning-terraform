terraform {
  backend "remote" {
    organization = "nickyiliwang"

    workspaces {
      name = "tf-k8s"
    }
  }
}