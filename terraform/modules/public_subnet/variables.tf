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

variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the public subnet"
  type = string
}

variable "public_subnet_map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnet"
  type        = bool
  default     = true
}

variable "create_public_subnets" {
  description = "Whether to create public subnets or use existing ones"
  type        = bool
  default     = true
}