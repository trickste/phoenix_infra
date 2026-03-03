resource "aws_network_acl" "nfi_nacl" {
  count = var.create_nacl ? length(var.subnets_cidr_ids) : 0
  vpc_id = var.vpc_id
  subnet_ids = [var.subnets_cidr_ids[count.index]]
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.env}_${var.subnet_type}_nacl_${var.azs[count.index]}"
  }
}
