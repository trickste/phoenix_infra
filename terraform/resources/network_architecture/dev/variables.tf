variable "create_vpc" {
  description = "Whether to create a new VPC or use an existing one"
  type        = bool
  default     = true
}

variable "product" {
  description = "Product name for resource naming"
  type        = string
  default     = "temp"
}

variable "create_security_group" {
  description = "Whether to create security groups for the application architecture"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the existing VPC to use (if create_vpc is false)"
  type        = string
  default     = null
}

variable "create_protected_subnets" {
  description = "Whether to create protected subnets"
  type        = bool
  default     = true
}

variable "protected_subnet_ids" {
  description = "List of protected subnet IDs"
  type        = list(string)
  default     = []
}

variable "create_protected_route_table" {
  description = "Whether to create a route table for protected subnets"
  type        = bool
  default     = true
}

variable "create_protected_nacl" {
  description = "Whether to create a NACL for protected subnets"
  type        = bool
  default     = true
}

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

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "subnet_azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/28", "10.0.2.0/28", "10.0.3.0/28"]
}

variable "public_subnet_map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnet"
  type        = bool
  default     = true
}

variable "protected_subnets_cidrs" {
  description = "List of CIDR blocks for protected subnets"
  type        = list(string)
  default     = ["10.0.10.0/28", "10.0.20.0/28", "10.0.30.0/28"]
}

variable "protected_nacl_ingress_rules" {
  description = "List of ingress rules for protected subnet NACL"
  type = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = [{
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
  }]
}

variable "protected_nacl_egress_rules" {
  description = "List of egress rules for protected subnet NACL"
  type = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = [{
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
  }]
}

variable "create_public_subnets" {
  description = "Whether to create public subnets or use existing ones"
  type        = bool
  default     = true
}

variable "create_public_route_table" {
  description = "Whether to create a route table for public subnets"
  type        = bool
  default     = true
}

variable "create_public_nacl" {
  description = "Whether to create a NACL for public subnets"
  type        = bool
  default     = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "public_nacl_ingress_rules" {
  description = "List of ingress rules for public subnet NACL, in real scenerio this will be the ip/subnet from which ssh will be allowed"
  type = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = [
    {
      rule_no    = 100
      protocol   = "tcp"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 22
      to_port    = 22
    },
    {
      rule_no    = 110
      protocol   = "tcp"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 1024
      to_port    = 65535
    }
  ]

}

variable "public_nacl_egress_rules" {
  description = "List of egress rules for public subnet NACL"
  type = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = [
    {
      rule_no    = 100
      protocol   = "tcp"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 65535
    }
  ]
}

variable "ami_security_group_ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow ssh inbound traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "ami_security_group_egress_rules" {
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

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}