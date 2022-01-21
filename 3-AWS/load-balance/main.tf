# load-balance/main.tf

resource "aws_lb" "tf_lb" {
    name = "tf-load-balancer"
    subnets = var.public_subnets
    security_groups = [var.public_sg]
    idle_timeout = 400
}