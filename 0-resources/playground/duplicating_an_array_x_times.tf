# ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]

variable "az_list" {
  default = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]
}

variable "repeat" {
  default = 5
}



locals {
  flattened = flatten(values({for i in range(5): i => var.az_list}))
  # expanded_az =  contains(["a", "b", "c"], "a")
  # expanded_az =  concat(var.az_list, var.az_list)
}


output "azlist" {
  value = local.flattened
}