resource "aws_vpc" "nfi_vpc" {
  count = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.env}_vpc"
  }
}