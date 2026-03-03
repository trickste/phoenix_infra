module "nfi_target_group" {
  source         = "../../../modules/target-group"
  port           = var.target_group_port
  protocol       = var.target_group_protocol
  tg_healthcheck = var.target_group_healthcheck
  vpc_id         = var.vpc_id == "" ? data.aws_vpc.nfi_vpc[0].id : var.vpc_id
  company_name   = var.company_name
  cloud_name     = var.cloud_name
  product        = var.product
  env            = var.env
}
