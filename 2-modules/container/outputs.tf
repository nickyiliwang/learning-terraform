output "application_access" {
  # https://www.terraform.io/language/expressions/for#result-types
  value = { for x in docker_container.app_container[*] : x.name => join(":", [x.ip_address], x.ports[*]["external"]) }
}

# OUTPUT
# application_access = [
#   {
#     "influxdb" = {
#       "application_access" = {
#         "influxdb-DEV-agyv" = "172.17.0.2:8186"
#       }
#     }
#     "nodered" = {
#       "application_access" = {
#         "nodered-DEV-ic5p" = "172.17.0.3:1980"
#       }
#     }
#   },
# ]