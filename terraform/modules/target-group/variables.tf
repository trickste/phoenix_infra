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

variable "port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Protocol for the target group"
  type        = string
  default = "HTTP"
}

variable "tg_healthcheck" {
  description = "Health check configuration for the target group"
  type = object({
    path                = string
    healthy_threshold   = number
    unhealthy_threshold = number
    interval            = number
    timeout             = number
    matcher             = string
  })
  default = {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}