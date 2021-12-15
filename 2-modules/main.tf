// Local-exec provisioner
resource "null_resource" "dockervolume" {
  provisioner "local-exec" {
    // bash script
    // chown change file owner
    // https://nodered.org/docs/getting-started/docker#using-a-host-directory-for-persistence-bind-mount
    // this command is  not idempotent
    # command = "mkdir noderedvol/ && sudo chown -R 1000:1000 noderedvol/"
    // checking if the folder exists
   
   // sleep 60 artificially introduces a dependency issue in the template
    command = "mkdir noderedvol/ || true && sudo chown -R 1000:1000 noderedvol/"
  }
}

module "image" {
  source = "./image"
  image_in = var.image[terraform.workspace]
}

resource "random_string" "random" {
  # creates x copies, using local values
  count   = local.container_count
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  depends_on = [null_resource.dockervolume]
  # creates x copies
  count = local.container_count
  // just a name so we can ref
  // we have to use [count.index] here to access the randomly generated names
  // adding workspace name to container name
  name  = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  // ref like var.xx, we are reffing a module output resource
  image = module.image.image_out

  ports {
    internal = var.int_port
    // ext_port is a map
    external = var.ext_port[terraform.workspace][count.index]
  }
  volumes {
    // host /home/pi/.node-red directory is bound to the container /data directory.
    container_path = "/data"
    // static paths are bad in modular deployments
    // https://www.terraform.io/docs/language/expressions/references.html
    // Use path.cwd to get the fs path of the current working directory
    host_path = "${path.cwd}/noderedvol"
  }
}
