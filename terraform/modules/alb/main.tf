locals {
  base_name = "${var.company_name}-${var.cloud_name}-${var.product}-${var.env}"
  alb_name  = substr("${local.base_name}-alb", 0, 32)
}

resource "aws_lb" "nfi_alb" {
  count = var.create_alb ? 1 : 0
  name               = local.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_groups

  enable_deletion_protection = false

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_alb"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.nfi_alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}