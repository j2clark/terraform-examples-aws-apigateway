data "archive_file" "hello_GET" {
  type = "zip"
  source_file = "lambda/hello_GET.js"
  output_path = "hello_GET.zip"
}

resource "aws_lambda_function" "hello_GET" {
  function_name = "${var.name_prefix}-hello"
  filename = "hello_GET.zip"
  role = data.aws_iam_role.execution_role.arn
  handler = "hello_GET.handler"
  runtime = "nodejs18.x"
  source_code_hash = data.archive_file.hello_GET.output_base64sha256

  tags = local.common_tags
}
