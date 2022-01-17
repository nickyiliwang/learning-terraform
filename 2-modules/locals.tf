// Using locals variables to store metadata, called deployment
locals {
  deployment = {
    nodered = {
      // lookup the map of ext_ports and get how many pods we are deploying with open ports
      container_count = length(var.ext_port["nodered"][terraform.workspace])
      image           = var.image["nodered"][terraform.workspace]
      int             = 1880
      ext             = var.ext_port["nodered"][terraform.workspace]
      volumes = [
        { container_path_for_each = "/data" },
      ]
    }
    influxdb = {
      image           = var.image["influxdb"][terraform.workspace]
      container_count = length(var.ext_port["influxdb"][terraform.workspace])
      int             = 8086
      ext             = var.ext_port["influxdb"][terraform.workspace]
      volumes = [
        { container_path_for_each = "/var/lib/influxdb" },
      ]
    }
    grafana = {
      image           = var.image["grafana"][terraform.workspace]
      container_count = length(var.ext_port["grafana"][terraform.workspace])
      int             = 3000
      ext             = var.ext_port["grafana"][terraform.workspace]
      volumes = [
        { container_path_for_each = "/var/lib/grafana" },
        { container_path_for_each = "/etc/grafana" }
      ]
    }
  }
}
