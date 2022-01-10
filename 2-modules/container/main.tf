
resource "random_string" "random" {
  count   = var.count_in
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "app_container" {
  count = var.count_in
  name  = join("-", [var.name_in, terraform.workspace, random_string.random[count.index].result])
  image = var.image_in
  ports {
    internal = var.int_port_in
    external = var.ext_port_in[count.index]
  }
  volumes {
    container_path = var.vol_container_path_in
    // replaces host_path
    volume_name = docker_volume.container_volume[count.index].name
  }

}

resource "docker_volume" "container_volume" {
  count = var.count_in
  // https://www.terraform.io/language/meta-arguments/lifecycle
  // Error: Instance cannot be destroyed
  // More control on when can the volume be destroyed
  name = "${var.name_in}-${random_string.random[count.index].result}-volume"
  lifecycle {
    prevent_destroy = false
  }
}