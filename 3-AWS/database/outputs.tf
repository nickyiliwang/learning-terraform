# database/outputs.tf

output "db_endpoint_out" {
  value = aws_db_instance.tf_db.endpoint
}