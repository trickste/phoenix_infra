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

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of ARNs of the Target Groups"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "health_check_grace_period" {
  description = "Health check grace period for the Auto Scaling Group"
  type        = number
  default     = 60  
}

variable "cpu_target_tracking_threshold_target_value" {
  description = "CPU utilization threshold for target tracking scaling policy"
  type        = number
  default     = 50.0
}
