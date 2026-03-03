module "nfi_aws_dev_protected_route_table" {
  source             = "../../../modules/route_table"
  depends_on         = [module.nfi_aws_dev_protected_subnet, module.nfi_aws_dev_vpc]
  create_route_table = var.create_protected_route_table
  company_name       = var.company_name
  cloud_name         = var.cloud_name
  env                = var.env
  azs                = var.subnet_azs
  subnet_type        = "protected"
  subnets_cidr_ids   = (!var.create_protected_subnets && var.protected_subnet_ids != null) ? var.protected_subnet_ids : module.nfi_aws_dev_protected_subnet.protected_subnet_ids
  vpc_id             = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
}

module "nfi_aws_dev_public_route_table" {
  source             = "../../../modules/route_table"
  depends_on         = [module.nfi_aws_dev_public_subnet, module.nfi_aws_dev_vpc]
  create_route_table = var.create_public_route_table
  company_name       = var.company_name
  cloud_name         = var.cloud_name
  env                = var.env
  azs                = var.subnet_azs
  subnet_type        = "public"
  subnets_cidr_ids   = (!var.create_public_subnets && var.public_subnet_ids != null) ? var.public_subnet_ids : module.nfi_aws_dev_public_subnet.public_subnet_ids
  vpc_id             = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  igw_id             = var.vpc_id != null ? data.aws_internet_gateway.vpc_igw[0].id : module.nfi_aws_dev_igw.igw_id
}