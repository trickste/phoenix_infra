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

variable "azs" {
  description = "List of availability zones for public subnets"
  type = list(string)
}

variable "protected_subnets_cidrs" {
  description = "List of CIDR blocks for protected subnets"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the protected subnet"
  type = string
}

variable "create_protected_subnets" {
  description = "Whether to create protected subnets or use existing ones"
  type        = bool
  default     = true
}