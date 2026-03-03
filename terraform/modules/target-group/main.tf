locals {
  base_name = "${var.company_name}-${var.cloud_name}-${var.product}-${var.env}"
  tg_name  = substr("${local.base_name}-tg", 0, 32)
}


resource "aws_lb_target_group" "nfi_tg" {
  name     = local.tg_name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = var.tg_healthcheck.path
    healthy_threshold   = var.tg_healthcheck.healthy_threshold
    unhealthy_threshold = var.tg_healthcheck.unhealthy_threshold
    interval            = var.tg_healthcheck.interval
    timeout             = var.tg_healthcheck.timeout
    matcher             = var.tg_healthcheck.matcher
  }

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_tg"
  }
}
