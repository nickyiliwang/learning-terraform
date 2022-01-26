# networking/main.tf

// assigning it to VPCs
resource "random_integer" "random" {
  min = 1
  max = 100
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf_vpc-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_subnet" "tf_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  // round-robin all availability zones
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    // subnets generally start the numbering from 1
    Name = "tf_public_sn_${count.index + 1}"
  }
}

// every public subnet created will have an association with the public rt
resource "aws_route_table_association" "tf_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.tf_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.tf_public_rt.id
}

resource "aws_subnet" "tf_private_subnet" {
  count             = var.private_sn_count
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "tf_private_sn_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}

// set the default vpc route table to a private rt
resource "aws_default_route_table" "tf_private_rt" {
  default_route_table_id = aws_vpc.tf_vpc.default_route_table_id

  tags = {
    Name = "tf_private_rt"
  }
}

resource "aws_route_table" "tf_public_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_public_rt"
  }
}

// default route to igw
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.tf_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_igw.id
}

// Public, ssh, and nginx ingress, open for egress
resource "aws_security_group" "tf_sg" {
  vpc_id      = aws_vpc.tf_vpc.id
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port = ingress.value.from
      to_port   = ingress.value.to
      protocol  = ingress.value.protocol
      // plural mostly means list
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    // -1 is all protocols
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

// grouping the 3 private subnets into a group
// for RDS deployment into these subnets
resource "aws_db_subnet_group" "tf_rds_subnet_group" {
  count = var.db_subnet_group ? 1 : 0
  name  = "tf_rds_subnet_group"
  // using all private subnets with the splat
  subnet_ids = aws_subnet.tf_private_subnet.*.id

  tags = {
    Name = "tf_rds_sng"
  }
}