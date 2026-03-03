output "public_subnet_ids" {
  value = [for subnet in aws_subnet.nfi_public_subnet : subnet.id]
}