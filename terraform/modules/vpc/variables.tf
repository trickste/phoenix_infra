variable "company_name" {
  description = "Name prefix"
  type        = string
}

variable "cloud_name" {
  description = "Cloud name"
  type        = string
}

variable "vpc_enable_dns_support" {
  description = "VPC DNS support"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "VPC DNS hostnames"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "create_vpc" {
  description = "Whether to create a new VPC or use an existing one"
  type        = bool
  default     = true
}