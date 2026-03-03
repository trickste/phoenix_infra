resource "aws_iam_role" "nfi_lambda_role" {
  name = "${var.company_name}_${var.cloud_name}_${var.product}_${var.env}_validation_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nfi_lambda_role_basic_exec" {
  role       = aws_iam_role.nfi_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
