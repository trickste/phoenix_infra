module "nfi_aws_dev_protected_nacl" {
  source           = "../../../modules/nacl"
  depends_on       = [module.nfi_aws_dev_protected_subnet, module.nfi_aws_dev_vpc]
  create_nacl      = var.create_protected_nacl
  company_name     = var.company_name
  cloud_name       = var.cloud_name
  env              = var.env
  vpc_id           = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  azs              = var.subnet_azs
  subnet_type      = "protected"
  subnets_cidr_ids = (!var.create_protected_subnets && var.protected_subnet_ids != null) ? var.protected_subnet_ids : module.nfi_aws_dev_protected_subnet.protected_subnet_ids
  ingress_rules    = var.protected_nacl_ingress_rules
  egress_rules     = var.protected_nacl_egress_rules
}


module "nfi_aws_dev_public_nacl" {
  source           = "../../../modules/nacl"
  depends_on       = [module.nfi_aws_dev_public_subnet, module.nfi_aws_dev_vpc]
  create_nacl      = var.create_public_nacl
  company_name     = var.company_name
  cloud_name       = var.cloud_name
  env              = var.env
  vpc_id           = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  azs              = var.subnet_azs
  subnet_type      = "public"
  subnets_cidr_ids = (!var.create_public_subnets && var.public_subnet_ids != null) ? var.public_subnet_ids : module.nfi_aws_dev_public_subnet.public_subnet_ids
  ingress_rules    = var.public_nacl_ingress_rules
  egress_rules     = var.public_nacl_egress_rules
}
