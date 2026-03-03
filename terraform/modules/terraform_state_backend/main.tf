resource "aws_s3_bucket" "nfi_terraform_state" {
  bucket = "${var.company_name}-${var.cloud_name}-${var.env}-terraform-state-backend"

  tags = {
    Name        = "${var.company_name}-${var.cloud_name}-${var.env}-terraform-state-backend"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.nfi_terraform_state.id

  versioning_configuration {
    status = var.s3_enable_versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.nfi_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.nfi_terraform_state.id

  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets
}

resource "aws_dynamodb_table" "nfi_dynamodb_terraform_lock" {
  name         = "${var.company_name}_${var.cloud_name}_${var.env}_terraform_state_backend_dynamo_db"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key

  attribute {
    name = var.dynamodb_attribute["name"]
    type = var.dynamodb_attribute["type"]
  }

  tags = {
    Name        = "${var.company_name}_${var.cloud_name}_${var.env}_terraform_state_backend_dynamo_db"
  }
}
