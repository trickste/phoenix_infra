resource "aws_launch_template" "nfi_lt" {
  name_prefix   = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_lt_"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_groups

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_lt"
    }
  }
}

resource "aws_autoscaling_group" "nfi_asg" {
  name                      = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.nfi_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_asg_cpu_scaling"
  autoscaling_group_name = aws_autoscaling_group.nfi_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.cpu_target_tracking_threshold_target_value
  }
}
