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
  description = "VPC ID for Lambda function"
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda function"
  type = list(string)
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type    = number
  default = 10
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type    = string
  default = "python3.11"
}

variable "lambda_security_group_id" {
  description = "Security Group ID for the Lambda function to allow outbound traffic to ALB"
  type = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer to set as environment variable in Lambda"
  type = string
}

variable "lambda_zip_path" {
  description = "Path to lambda zip file"
  type        = string
}
