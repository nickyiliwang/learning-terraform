# networking/outputs.tf

output "vpc_id" {
    value = aws_vpc.tf_vpc.id
}