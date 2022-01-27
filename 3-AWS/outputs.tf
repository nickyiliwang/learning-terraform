# root/outputs.tf

output "load_balancer_endpoint" {
    value = module.load-balance.lb_endpoint
}