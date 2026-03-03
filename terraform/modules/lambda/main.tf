resource "aws_lambda_function" "nfi_lambda" {
  function_name = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_validation_lambda"
  role          = aws_iam_role.nfi_lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      ALB_DNS = var.alb_dns_name
    }
  }
}
