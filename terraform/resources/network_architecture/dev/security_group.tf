module "nfi_ami_security_group" {
  source                = "../../../modules/security_group"
  create_security_group = var.create_security_group
  company_name          = var.company_name
  cloud_name            = var.cloud_name
  product               = var.product
  env                   = var.env
  vpc_id                = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  ingress_rules         = var.ami_security_group_ingress_rules
  egress_rules          = var.ami_security_group_egress_rules
  resource_name         = "ami"
}