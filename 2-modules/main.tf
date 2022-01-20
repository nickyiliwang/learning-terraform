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
  volumes_in = each.value.volumes
}
