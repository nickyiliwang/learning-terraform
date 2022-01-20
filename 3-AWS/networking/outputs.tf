# networking/outputs.tf

output "vpc_id" {
  value = aws_vpc.tf_vpc.id
}

output "tf_rds_subnet_group_name_out" {
  value = aws_db_subnet_group.tf_rds_subnet_group[0].name
}

output "rds_sg_out" {
  value = aws_security_group.tf_sg["rds"].id
}