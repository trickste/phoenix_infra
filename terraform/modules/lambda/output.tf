output "lambda_name" {
  value = aws_lambda_function.nfi_lambda.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.nfi_lambda.arn
}
