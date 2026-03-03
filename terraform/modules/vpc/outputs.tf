output "vpc_id" {
  value = length(aws_vpc.nfi_vpc) > 0 ? aws_vpc.nfi_vpc[0].id : null
}
