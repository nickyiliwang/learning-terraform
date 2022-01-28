data "terrform_remote_state" "kubeconfig_from_node" {
  backend = "remote"
  config = {
    organization = "nickyiliwang"
    workspaces = {
      name = "nick-dev"
    }
  }
}
