
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

  provisioner "local-exec" {
    command    = "echo ${self.name}: ${self.ip_address}:${join("", [for x in self.ports[*]["external"] : x])} >> containers.txt"
    on_failure = fail
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f containers.txt"
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
  provisioner "local-exec" {
    # https://www.terraform.io/language/resources/provisioners/syntax#destroy-time-provisioners
    when    = destroy
    command = "mkdir ${path.cwd}/../backup/"
    # https://www.terraform.io/language/resources/provisioners/syntax#failure-behavior
    on_failure = continue
  }
  provisioner "local-exec" {
    when = destroy
    # https://www.howtogeek.com/248780/how-to-compress-and-extract-files-using-the-tar-command-on-linux/
    # tar command ref
    # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume#read-only
    # reference to the self.mountpoint
    command    = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"
    on_failure = fail
  }
}