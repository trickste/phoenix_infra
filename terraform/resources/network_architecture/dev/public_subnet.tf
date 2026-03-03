module "nfi_aws_dev_public_subnet" {
  source                = "../../../modules/public_subnet"
  create_public_subnets = var.create_public_subnets
  company_name          = var.company_name
  cloud_name            = var.cloud_name
  env                   = var.env
  vpc_id                = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  azs                   = var.subnet_azs
  public_subnets_cidrs  = var.public_subnets_cidrs
}
