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
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "random2" {
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  // just a name so we can ref
  name  = join("-", ["nodered", random_string.random.result])
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
    # external = 1880
  }
}

resource "docker_container" "nodered_container_2" {
  // just a name so we can ref
  name  = join("-", ["nodered", random_string.random2.result])
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
    # external = 1880
  }
}

output "local-ip-external-port_pod1" {
  value       = join(":", [docker_container.nodered_container.ip_address, docker_container.nodered_container.ports[0].external])
  description = "Local ip:external-port"
}

output "container-name_pod1" {
  value       = docker_container.nodered_container.name
  description = "The name of the container"
}

output "local-ip-external-port_pod2" {
  value       = join(":", [docker_container.nodered_container_2.ip_address, docker_container.nodered_container_2.ports[0].external])
  description = "Local ip:external-port"
}

output "container-name_pod2" {
  value       = docker_container.nodered_container_2.name
  description = "The name of the container"
}
