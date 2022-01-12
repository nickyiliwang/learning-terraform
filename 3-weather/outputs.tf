output "application_access" {
  value       = [for x in module.container[*] : x]
  description = "Name and socket for each application"
}