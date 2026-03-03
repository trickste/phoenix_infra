resource "aws_security_group" "nfi_security_group" {
  count = var.create_security_group ? 1 : 0
  name   = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_${var.resource_name}_security_group"

  vpc_id = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      protocol   = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = egress.value.description
      protocol   = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_${var.resource_name}_security_group"
  }
}
