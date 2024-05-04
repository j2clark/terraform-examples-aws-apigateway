data "archive_file" "lambda_basic_package" {
  type = "zip"
  source_file = "lambda/get.js"
  output_path = "get.zip"
}

resource "aws_lambda_function" "lambda_get" {
  function_name = "${var.name_prefix}-hello"
  filename = "get.zip"
  role = data.aws_iam_role.execution_role.arn
  handler = "get.handler"
  runtime = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_basic_package.output_base64sha256

  tags = local.common_tags
}

#output "lambda_get" {
#  value = aws_lambda_function.lambda_get.function_name
#}