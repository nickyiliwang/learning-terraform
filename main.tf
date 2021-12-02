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

resource "random_string" "random" {-


  # creates 2 copies
  count   = 1
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  # creates 2 copies
  count = 1
  // just a name so we can ref
  // we have to use [count.index] here to access the randomly generated names
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
    # external = 1880
  }
}

output "local-ip-plus-external-ports" {
  # we are using a for loop + the join function to keep the code DRY
  value       = [for i in docker_container.nodered_container[*]: join(":", [i.ip_address, i.ports[0].external])] 
  description = "Local ip:external-port"
}

output "container-names" {
# we are using the splat ([*]) syntax here to make our output DRY
  value       = docker_container.nodered_container[*].name
  description = "The name of the container"
}