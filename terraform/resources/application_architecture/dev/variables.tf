variable "company_name" {
  description = "Name prefix"
  type        = string
  default     = "nfi"
}

variable "cloud_name" {
  description = "Cloud name"
  type        = string
  default     = "aws"
}

variable "product" {
  description = "Product name"
  type        = string
  default     = "phoenix"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "create_alb" {
  description = "Whether to create the ALB"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID of the existing VPC to use (if create_vpc is false)"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "create_security_group" {
  description = "Whether to create the security group for the ALB"
  type        = bool
  default     = true
}

variable "alb_security_group_ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "alb_security_group_egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "asg_security_group_ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow HTTP traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "asg_security_group_egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "health_check_grace_period" {
  description = "Health check grace period for the ASG"
  type        = number
  default     = 300
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
  default     = 3
}

variable "cpu_target_tracking_threshold_target_value" {
  description = "Target value for CPU utilization in target tracking scaling policy"
  type        = number
  default     = 50.0
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 8080
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_group_healthcheck" {
  description = "Health check configuration for the target group"
  type = object({
    path                = string
    healthy_threshold   = number
    unhealthy_threshold = number
    interval            = number
    timeout             = number
    matcher             = string
  })
  default = {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-central-1"
}