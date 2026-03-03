module "nfi_dev_alb" {
  source                     = "../../../modules/alb"
  depends_on                 = [module.nfi_alb_security_group, module.nfi_target_group]
  create_alb                 = var.create_alb
  company_name               = var.company_name
  cloud_name                 = var.cloud_name
  product                    = var.product
  env                        = var.env
  vpc_id                     = var.vpc_id == "" ? data.aws_vpc.nfi_vpc[0].id : var.vpc_id
  subnet_ids                 = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.nfi_protected_subnets.ids
  enable_deletion_protection = var.enable_deletion_protection
  security_groups            = [module.nfi_alb_security_group.security_group_id]
  target_group_arn           = module.nfi_target_group.target_group_arn
}