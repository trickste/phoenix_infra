variable "env" {
  description = "Environment name"
  type        = string
}

variable "company_name" {
  description = "Company name for tagging"
  type        = string
}

variable "cloud_name" {
  description = "Cloud provider name for tagging"
  type        = string
}

variable "s3_enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = string
  default     = "Enabled"
}

variable "s3_sse_algorithm" {
  description = "Server-side encryption algorithm for the S3 bucket"
  type        = string
  default     = "AES256"
}

variable "s3_block_public_acls" {
  description = "Block public ACLs for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_block_public_policy" {
  description = "Block public bucket policies for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_ignore_public_acls" {
  description = "Ignore public ACLs for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_restrict_public_buckets" {
  description = "Restrict public buckets for the S3 bucket"
  type        = bool
  default     = true
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for the DynamoDB table ( PROVISIONED / PAY_PER_REQUEST )"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_hash_key" {
  description = "Hash key for the DynamoDB table"
  type        = string
  default     = "LockID"
}

variable "dynamodb_attribute" {
  description = ""
  type = object({
    name = string
    type = string
  })
  default = {
    name = "LockID"
    type = "S"
  }
}