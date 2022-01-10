// nodered_image => container_image
resource "docker_image" "container_image" {
  name = var.image_in
}
