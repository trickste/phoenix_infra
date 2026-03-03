module "nfi_aws_dev_igw" {
  source       = "../../../modules/igw"
  create_igw   = var.vpc_id != null && data.aws_internet_gateway.vpc_igw[0].id != "" ? false : true
  depends_on   = [module.nfi_aws_dev_vpc]
  vpc_id       = var.vpc_id != null ? var.vpc_id : module.nfi_aws_dev_vpc.vpc_id
  company_name = var.company_name
  cloud_name   = var.cloud_name
  env          = var.env
}