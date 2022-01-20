# root/variable.tf

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {
  //Oregon region
  default = "us-west-2"
}


variable "access_ip" {
  type = string
}