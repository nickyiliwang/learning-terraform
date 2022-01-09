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

module "container" {
  source = "./container"
  depends_on = [null_resource.dockervolume]
  # creates x copies
  count = local.container_count
  // just a name so we can ref
  // we have to use [count.index] here to access the randomly generated names
  // adding workspace name to container name
  // name => name_in, passing into module
  name_in  = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  // ref like var.xx, we are reffing a module output resource
  // image => image_in passing into module
  image_in = module.image.image_out

  // ports
  int_port_in = var.int_port
  ext_port_in = var.ext_port[terraform.workspace][count.index]
  
  // volumes
  vol_container_path_in = "/data"
  vol_host_path_in = "${path.cwd}/noderedvol"
  
}
