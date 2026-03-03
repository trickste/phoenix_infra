module "nfi_aws_dev_vpc" {
  source                   = "../../../modules/vpc"
  create_vpc               = var.vpc_id == null ? var.create_vpc : false
  company_name             = var.company_name
  cloud_name               = var.cloud_name
  vpc_cidr                 = var.vpc_cidr
  vpc_enable_dns_support   = var.vpc_enable_dns_support
  vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames
  env                      = var.env
}