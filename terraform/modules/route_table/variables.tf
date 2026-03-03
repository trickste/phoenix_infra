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

variable "subnets_cidr_ids" {
  description = "List of CIDR blocks for protected subnets"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the protected subnet"
  type = string
}

variable "subnet_type" {
  description = "Subnet type (e.g., public, private)"
  type        = string
}

variable "igw_id" {
  description = "Internet Gateway ID for the route table"
  type        = string
  default     = null
}

variable "create_route_table" {
  description = "Whether to create a route table"
  type        = bool
  default     = true
}