output "image_out" {
  // you can cofigure what you what to output
  // here, we always want the lastest image
  value = docker_image.container_image.latest
}