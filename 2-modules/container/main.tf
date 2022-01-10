resource "docker_container" "nodered_container" {
  name  = var.name_in
  image = var.image_in

  ports {
    internal = var.int_port_in
    external = var.ext_port_in
  }

  volumes {
    container_path = var.vol_container_path_in
    // replaces host_path
    volume_name = docker_volume.container_volume.name
  }

}

resource "docker_volume" "container_volume" {
  // https://www.terraform.io/language/meta-arguments/lifecycle
  // Error: Instance cannot be destroyed
  // More control on when can the volume be destroyed
  name = "${var.name_in}-volume"
  lifecycle {
    prevent_destroy = false
  }
}