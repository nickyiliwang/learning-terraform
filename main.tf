terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {}

// Local-exec provisioner
resource "null_resource" "dockervolume" {
  provisioner "local-exec" {
    // bash script
    // chown change file owner
    // https://nodered.org/docs/getting-started/docker#using-a-host-directory-for-persistence-bind-mount
    // this command is  not idempotent
    # command = "mkdir noderedvol/ && sudo chown -R 1000:1000 noderedvol/"
    // checking if the folder exists
    command = "mkdir noderedvol/ || true && sudo chown -R 1000:1000 noderedvol/"
  }
}


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
  type = list(any)


  validation {
  // since it's a list, we are spreading the values and validating against the min/max range
    condition     = max(var.ext_port...) <= 65535 &&  min(var.ext_port...) > 0
    error_message = "Must provide valid external port range 0 - 65535."
  }
}

locals {
  container_count = length(var.ext_port)
}

resource "docker_image" "nodered_image" {
  // must be official name
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  # creates x copies, using local values
  count   = local.container_count
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  # creates x copies
  count = local.container_count
  // just a name so we can ref
  // we have to use [count.index] here to access the randomly generated names
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = var.int_port
    // ext_ports are now a list
    external = var.ext_port[count.index]
  }
  volumes {
    // host /home/pi/.node-red directory is bound to the container /data directory.
    container_path = "/data"
    host_path      = "/home/ubuntu/environment/noderedvol"
  }
}

output "container-names" {
  # we are using the splat ([*]) syntax here to make our output DRY
  value       = docker_container.nodered_container[*].name
  description = "The name of the container"
}

# OutPuts
output "local-ip-plus-external-ports" {
  # we are using a for loop + the join function to keep the code DRY
  value       = [for i in docker_container.nodered_container[*] : join(":", [i.ip_address, i.ports[0].external])]
  description = "Local ip:external-port"
}