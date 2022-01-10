// Using locals variables to store metadata, called deployment
locals {
  deployment = {
    nodered = {
      // lookup the map of ext_ports and get how many pods we are deploying with open ports
      container_count = length(var.ext_port["nodered"][terraform.workspace])
      image           = var.image["nodered"][terraform.workspace]
      // ports
      int            = 1880
      ext            = var.ext_port["nodered"][terraform.workspace]
      container_path = "/data"
    }
    influxdb = {
      image           = var.image["influxdb"][terraform.workspace]
      container_count = length(var.ext_port["influxdb"][terraform.workspace])
      // ports
      int            = 8086
      ext            = var.ext_port["influxdb"][terraform.workspace]
      container_path = "/var/lib/influxdb"
    }
  }
}

module "image" {
  source = "./image"
  // https://www.terraform.io/language/meta-arguments/for_each
  for_each = local.deployment
  // accessing local variables
  image_in = each.value.image
}

module "container" {
  source   = "./container"
  count_in = each.value.container_count
  for_each = local.deployment
  name_in  = each.key
  image_in = module.image[each.key].image_out

  // ports
  int_port_in = each.value.int
  ext_port_in = each.value.ext

  // volumes
  vol_container_path_in = each.value.container_path
}
