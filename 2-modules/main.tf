// Using locals variables to store metadata, called deployment
locals {
  deployment = {
    nodered = {
      image = var.image["nodered"][terraform.workspace]
    }
    influxdb = {
      image = var.image["influxdb"][terraform.workspace]
    }
  }
}

module "image" {
  source   = "./image"
  // https://www.terraform.io/language/meta-arguments/for_each
  for_each = local.deployment
  // accessing local variables
  image_in = each.value.image
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
  # creates x copies
  count = local.container_count
  // just a name so we can ref
  // we have to use [count.index] here to access the randomly generated names
  // adding workspace name to container name
  // name => name_in, passing into module
  name_in = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  // ref like var.xx, we are reffing a module output resource
  // image => image_in passing into module
  image_in = module.image["nodered"].image_out

  // ports
  int_port_in = var.int_port
  ext_port_in = var.ext_port[terraform.workspace][count.index]

  // volumes
  vol_container_path_in = "/data"
}
