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

variable "subnet_type" {
  description = "Subnet type (e.g., public, private, protected)"
  type        = string
}

variable "azs" {
  description = "List of availability zones for subnets"
  type = list(string)
}

variable "subnets_cidr_ids" {
  description = "List of subnet CIDR blocks and IDs"
  type = list(string)
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = []
}

variable "create_nacl" {
  description = "Whether to create a network ACL"
  type        = bool
  default     = true
}