module "nfi_lambda_alb_caller" {
  source                   = "../../../modules/lambda"
  company_name             = var.company_name
  cloud_name               = var.cloud_name
  product                  = var.product
  env                      = var.env
  vpc_id                   = var.vpc_id == "" ? data.aws_vpc.nfi_vpc[0].id : var.vpc_id
  subnet_ids               = length(var.protected_subnet_ids) > 0 ? var.protected_subnet_ids : data.aws_subnets.nfi_protected_subnets.ids
  alb_dns_name             = var.alb_dns_name == "" ? data.aws_lb.nfi_alb.dns_name : var.alb_dns_name
  lambda_security_group_id = module.nfi_lambda_security_group.security_group_id
  lambda_timeout           = var.lambda_timeout
  lambda_handler           = var.lambda_handler
  lambda_runtime           = var.lambda_runtime
  lambda_zip_path          = "${path.module}/../lambda_function_code/lambda.zip"
}