# networking/main.tf

// assigning it to VPCs
resource "random_integer" "random" {
  min = 1
  max = 100
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
  //The following VPC attributes determine the DNS support provided for your VPC. 
  //Instance launched into the VPC receives a public DNS hostname 
  //if it is assigned a public IPv4 address or an Elastic IP address at creation. 
  //If you enable both attributes for a VPC that didn't previously have them both enabled, 
  //instances that were already launched into that VPC receive public DNS hostnames if they have a public IPv4 address or an Elastic IP address.
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf_vpc-${random_integer.random.id}"
  }
}