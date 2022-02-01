//--------------------------------------------------------------------
// Variables



//--------------------------------------------------------------------
// Modules
module "compute" {
  source  = "app.terraform.io/nickyiliwang/compute/aws"
  version = "1.0.0"

  aws_region          = "us-east-1"
  public_key_material = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDL/8oGw3zyxma9znZHfeRK4G5Y1QbK3n47VdgC07wKr1cMDknEHpN2ef/JAPw2zTURn+WbmanDwA8ogCG27HPFsXDvFF1vnNloh1GIQ94CvNE0rnNWhiZijPPdm2PgSFovwDma4auDKJjWXSZ5/ZfzxNHm1iHFF+50+YRqZM3loEPOp9lVKz6t3WC0O/+tmuk2Cd/Xal5hCUddH5FfhfpFkt8mo1usugb0ApsVKTUK5Mk9GCkBEOn1xrqqeJxdRnwkQEIShEQpf2hOF8IUotsv8vyWNXZrq09P0LB2HeLuu5t2iJmNmWQr+3mW7dNZDDOVdikydGmr7m/cw1K/fQe5 ubuntu@ip-172-31-95-232"
  public_sg           = module.networking.public_sg
  public_subnets      = module.networking.public_subnets
}

module "networking" {
  source  = "app.terraform.io/nickyiliwang/networking/aws"
  version = "1.0.0"

  access_ip  = "0.0.0.0/0"
  aws_region = "us-east-1"
}