output "bucket_name" {
  value = aws_s3_bucket.nfi_terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.nfi_dynamodb_terraform_lock.name
}
