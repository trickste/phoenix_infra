locals {
  base_name         = "${var.company_name}-${var.cloud_name}-${var.product}-${var.env}"
  network_base_name = "${var.company_name}_${var.cloud_name}_${var.env}"
  effective_vpc_id  = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.nfi_vpc[0].id
}

data "aws_vpc" "nfi_vpc" {
  count = var.vpc_id == "" ? 1 : 0

  filter {
    name   = "tag:Name"
    values = ["${local.network_base_name}_vpc"]
  }
}

data "aws_subnets" "nfi_protected_subnets" {
  filter {
    name = "tag:Name"
    values = [
      "${local.network_base_name}_protected_subnet_0",
      "${local.network_base_name}_protected_subnet_1",
      "${local.network_base_name}_protected_subnet_2"
    ]
  }

  filter {
    name   = "vpc-id"
    values = [local.effective_vpc_id]
  }
}

data "aws_lb" "nfi_alb" {
  name = "${local.base_name}-alb"
}