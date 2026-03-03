module "terraform_backend" {
  source       = "../../modules/terraform_state_backend"
  company_name = "nfi"
  cloud_name   = "aws"
  env          = "dev"
}