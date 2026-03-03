module "nfi_asg" {
  source                                     = "../../../modules/asg"
  company_name                               = var.company_name
  cloud_name                                 = var.cloud_name
  product                                    = var.product
  env                                        = var.env
  subnet_ids                                 = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.nfi_protected_subnets.ids
  security_groups                            = [module.nfi_asg_security_group.security_group_id]
  health_check_grace_period                  = var.health_check_grace_period
  ami_id                                     = var.ami_id != "" ? var.ami_id : data.aws_ami.nfi_latest_web_server_ami.id
  instance_type                              = var.instance_type
  target_group_arns                          = [module.nfi_target_group.target_group_arn]
  min_size                                   = var.min_size
  max_size                                   = var.max_size
  desired_capacity                           = var.desired_capacity
  cpu_target_tracking_threshold_target_value = var.cpu_target_tracking_threshold_target_value
}