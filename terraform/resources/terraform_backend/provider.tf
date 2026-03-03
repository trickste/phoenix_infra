terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

variable "region" {
  description = "The AWS region to use for the provider."
  type        = string
  default     = "eu-central-1"
}