module "nfi_aws_dev_protected_subnet" {
  source                   = "../../../modules/protected_subnet"
  create_protected_subnets = var.create_protected_subnets
  company_name             = var.company_name
  cloud_name               = var.cloud_name
  env                      = var.env
  vpc_id                   = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  azs                      = var.subnet_azs
  protected_subnets_cidrs  = var.protected_subnets_cidrs
}
