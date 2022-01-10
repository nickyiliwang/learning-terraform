variable "image" {
  type        = map(any)
  description = "image for container depending on environment"
  default = {
    nodered = {
      DEV  = "nodered/node-red:latest"
      PROD = "nodered/node-red:latest-minimal"
    }
    influxdb = {
      DEV  = "quay.io/influxdb/influxdb:v2.0.2"
      PROD = "quay.io/influxdb/influxdb:v2.0.2"
    }
  }
}

variable "int_port" {
  type    = number
  default = 1880

  validation {
    condition     = var.int_port == 1880
    error_message = "The internal port must be 1880."
  }
}

variable "ext_port" {
  type = map(any)


  # # validating different ports for different env by accessing the ext_port map
  # # DEV
  # validation {
  #   condition     = max(var.ext_port["DEV"]...) <= 65535 && min(var.ext_port["DEV"]...) >= 1980
  #   error_message = "Must provide valid external port range 0 - 65535."
  # }
  # # PROD
  # validation {
  #   condition     = max(var.ext_port["PROD"]...) <= 65535 && min(var.ext_port["PROD"]...) >= 1880
  #   error_message = "Must provide valid external port range 0 - 65535."
  # }
}