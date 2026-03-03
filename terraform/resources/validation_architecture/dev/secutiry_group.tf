module "nfi_lambda_security_group" {
  source                = "../../../modules/security_group"
  create_security_group = var.create_lambda_security_group
  company_name          = var.company_name
  cloud_name            = var.cloud_name
  product               = var.product
  env                   = var.env
  vpc_id                = var.vpc_id == "" ? data.aws_vpc.nfi_vpc[0].id : var.vpc_id
  ingress_rules         = var.lambda_security_group_ingress_rules
  egress_rules          = var.lambda_security_group_egress_rules
  resource_name         = "lambda_alb"
}