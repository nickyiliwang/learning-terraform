terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nodered_image" {
  // must be official name
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  # creates x copies
  count   = var.resource_count
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  # creates x copies
  count = var.resource_count
  // just a name so we can ref
  // we have to use [count.index] here to access the randomly generated names
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = var.int_port
    # external = 1880
  }
}
