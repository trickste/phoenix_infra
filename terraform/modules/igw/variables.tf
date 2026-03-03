variable "company_name" {
  description = "Name prefix"
  type        = string
}

variable "cloud_name" {
  description = "Cloud name"
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

variable "create_igw" {
  description = "Whether to create the Internet Gateway"
  type        = bool
  default     = true
}