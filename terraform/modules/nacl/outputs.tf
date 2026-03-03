output "nacl_ids" {
  value = { for key, nacl in aws_network_acl.nfi_nacl : key => nacl.id }
}