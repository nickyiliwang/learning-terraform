terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {}

# Variables
variable "int_port" {
  type    = number
  default = 1880

  validation {
    condition     = var.int_port == 1880
    error_message = "The internal port must be 1880."
  }
}

variable "ext_port" {
  type = number

  validation {
    condition     = var.ext_port <= 65535 && var.ext_port > 0
    error_message = "Must provide valid external port range 0 - 65535."
  }
}

variable "resource_count" {
  type    = number
  default = 1
}


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
    external = var.ext_port
  }
}

# OutPuts
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