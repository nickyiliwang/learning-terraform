# output "container-names" {
#   value       = module.container[*].container-names-out
#   description = "The name of the container"
# }

# output "local-ip-plus-external-ports" {
#   // just flattening the structure of child module output
#   value       = flatten(module.container[*].local-ip-plus-external-ports-out)
#   description = "Local ip:external-port"
# }