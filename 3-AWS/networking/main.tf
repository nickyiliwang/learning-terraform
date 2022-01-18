# networking/main.tf

// assigning it to VPCs
resource "random_integer" "random" {
  min = 1
  max = 100
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf_vpc-${random_integer.random.id}"
  }
}

resource "aws_subnet" "tf_public_subnet" {
  count = length(var.public_cidrs)
  vpc_id = aws_vpc.tf_vpc.id 
  cidr_block = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  // hardcoding for now
  availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"][count.index]
  
  tags = {
    // subnets generally start the numbering from 1
    Name = "tf_public_sn_${count.index + 1}"
  }
}

resource "aws_subnet" "tf_private_subnet" {
  count = length(var.private_cidrs)
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = var.private_cidrs[count.index]
  availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"][count.index]
  
  tags = {
    Name = "tf_private_sn_${count.index + 1}"
  }
}


