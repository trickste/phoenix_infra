output "nfi_protected_alb_dns_name" {
  value = module.nfi_dev_alb.alb_dns_name
}

output "vpc_id" {
  value = var.vpc_id == null ? data.aws_vpc.nfi_vpc[0].id : var.vpc_id
}

output "protected_subnet_ids" {
  value = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.nfi_protected_subnets.ids
}

