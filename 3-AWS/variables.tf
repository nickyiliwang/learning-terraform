# root/variable.tf

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {
  //Oregon region
  # default = "us-west-2"
  // Stockholm with free tier t3.micro ec2
  default = "eu-north-1"
}


variable "access_ip" {
  type = string
}

# database variables

variable "db_name" {
  type = string
}
variable "db_user" {
  type      = string
  sensitive = true
}
variable "db_password" {
  type      = string
  sensitive = true
}