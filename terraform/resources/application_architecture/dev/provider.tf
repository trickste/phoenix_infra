terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "nfi-aws-dev-terraform-state-backend"
    key            = "nfi/aws/phoenix/dev/application/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "nfi_aws_dev_terraform_state_backend_dynamo_db"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}