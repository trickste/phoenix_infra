output "igw_id" {
  value = var.create_igw ? aws_internet_gateway.nfi_igw[0].id : null
}