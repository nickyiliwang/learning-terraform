variable "image" {
  type        = map(any)
  description = "image for container depending on environment"

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


  # validating different ports for different env by accessing the ext_port map
  # DEV
  validation {
    condition     = max(var.ext_port["DEV"]...) <= 65535 && min(var.ext_port["DEV"]...) >= 1980
    error_message = "Must provide valid external port range 0 - 65535."
  }
  # PROD
  validation {
    condition     = max(var.ext_port["PROD"]...) <= 65535 && min(var.ext_port["PROD"]...) >= 1880
    error_message = "Must provide valid external port range 0 - 65535."
  }

}

locals {
  // lookup the map of ext_ports and get how many pods we are deploying with open ports
  container_count = length(var.ext_port[terraform.workspace])
}