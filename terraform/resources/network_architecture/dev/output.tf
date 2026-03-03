output "vpc_id" {
  value = (var.vpc_id == null && var.create_vpc) ? module.nfi_aws_dev_vpc.vpc_id : var.vpc_id
}

output "protected_subnet_ids" {
  value = var.create_protected_subnets ? module.nfi_aws_dev_protected_subnet.protected_subnet_ids : var.protected_subnet_ids
}

output "public_subnet_ids" {
  value = var.create_public_subnets ? module.nfi_aws_dev_public_subnet.public_subnet_ids : var.public_subnet_ids
}

output "nfi_ami_security_group_id" {
  value = module.nfi_ami_security_group.security_group_id
}