terraform {
    backend "remote" {
        organization = "nickyiliwang"
        
        workspaces {
            name = "tf-dev-repo"
        }
    }
}