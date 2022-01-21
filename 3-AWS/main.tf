# root/main.tf

module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  public_sn_count  = 2
  private_sn_count = 3
  // 200 aws hard limit
  max_subnets = 20
  // even nums for public, max 255 to have enough subnets
  public_cidrs    = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs   = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group = true
}

# module "database" {
#   source                 = "./database"
#   db_storage             = 10 # 1 Gib = 1024mb
#   db_engine_version      = "5.7.22"
#   db_instance_class      = "db.t2.micro"
#   db_name                = "rancher"
#   db_user                = "nick"
#   db_password            = "asd123asd123"
#   db_identifier          = "tf-db"
#   skip_db_final_snapshot = true
#   db_subnet_group_name   = module.networking.tf_rds_subnet_group_name_out
#   vpc_security_group_ids = [module.networking.rds_sg_out]
# }

module "load-balance" {
  source = "./load-balance"
  public_sg = module.networking.public_sg_out
  public_subnets = module.networking.public_subnets
}