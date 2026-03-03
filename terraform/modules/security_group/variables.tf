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


variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = string
    protocol   = string
    cidr_blocks = list(string)
    from_port  = number
    to_port    = number
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description = string
    protocol   = string
    cidr_blocks = list(string)
    from_port  = number
    to_port    = number
  }))
  default = []
}

variable "resource_name" {
  description = "Resource name for tagging"
  type        = string
}

variable "create_security_group" {
  description = "Whether to create the security group"
  type        = bool
  default     = true
}