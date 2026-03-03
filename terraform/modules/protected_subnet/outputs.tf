output "protected_subnet_ids" {
  value = [for subnet in aws_subnet.nfi_protected_subnet : subnet.id]
}