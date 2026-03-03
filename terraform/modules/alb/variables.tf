variable "company_name" {
  description = "Name prefix"
  type        = string
}

variable "cloud_name" {
  description = "Cloud name"
  type        = string
}

variable "product" {
  description = "Product name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Internet Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ALB"
  type = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type    = bool
  default = true
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type    = bool
  default = false
}

variable "create_alb" {
  description = "Whether to create the ALB"
  type    = bool
  default = true
}

variable "target_group_arn" {
  description = "ARN of the Target Group to associate with the ALB listener"
  type        = string
}