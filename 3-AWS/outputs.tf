# root/outputs.tf

output "load_balancer_endpoint" {
  value = module.load-balance.lb_endpoint
}

output "instances" {
  value = { for x in module.compute.instances : x.tags.Name => "${x.public_ip}:${module.compute.tg_attach_port_out}" }
  sensitive = true
}
