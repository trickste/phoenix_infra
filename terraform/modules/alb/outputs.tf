output "alb_arn" {
  value = aws_lb.nfi_alb[0].arn
}

output "alb_dns_name" {
  value = aws_lb.nfi_alb[0].dns_name
}