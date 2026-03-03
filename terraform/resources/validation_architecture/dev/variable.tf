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

variable "product" {
  description = "Product name"
  type        = string
  default     = "phoenix"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID for Lambda function"
  type        = string
  default     = ""
}

variable "protected_subnet_ids" {
  description = "List of protected subnet IDs for Lambda function"
  type        = list(string)
  default     = []
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 10
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.11"
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer to set as environment variable in Lambda"
  type        = string
  default     = ""
}

variable "create_lambda_security_group" {
  description = "Whether to create a security group for the Lambda function"
  type        = bool
  default     = true
}

variable "lambda_security_group_ingress_rules" {
  description = "List of ingress rules for the Lambda security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow HTTP traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "lambda_security_group_egress_rules" {
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