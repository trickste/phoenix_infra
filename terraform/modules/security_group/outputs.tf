output "security_group_id" {
  value = aws_security_group.nfi_security_group[0].id
}