locals {
  base_name         = "${var.company_name}_${var.product}_${var.env}"
  network_base_name = "${var.company_name}_${var.cloud_name}_${var.env}"
  effective_vpc_id  = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.nfi_vpc[0].id
}

data "aws_ami" "nfi_latest_web_server_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:Name"
    values = ["${local.base_name}_web_server_ami"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
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