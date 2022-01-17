
resource "docker_volume" "container_volume" {
  // not relying on the number of container provisoned instead of number of volume paths
  count = var.volume_count
  name  = "${var.volume_name}-${count.index}"

  // https://www.terraform.io/language/meta-arguments/lifecycle
  // You get this error if its true => Error: Instance cannot be destroyed
  // More control on when can the volume be destroyed
  lifecycle {
    prevent_destroy = false
  }
  provisioner "local-exec" {
    # https://www.terraform.io/language/resources/provisioners/syntax#destroy-time-provisioners
    when    = destroy
    command = "mkdir ${path.cwd}/../backup/"
    # https://www.terraform.io/language/resources/provisioners/syntax#failure-behavior
    on_failure = continue
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"
    on_failure = fail
  }
}