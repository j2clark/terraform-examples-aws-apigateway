resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  parent_id = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part = "hello"
}

resource "aws_api_gateway_method" "hello_OPTIONS" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_OPTIONS" {
  depends_on = [aws_api_gateway_method.hello_OPTIONS]
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_OPTIONS.http_method
  type          = "MOCK"
  request_templates = {
    "application/json" = <<JSON
{
    "statusCode": 200
}
JSON
  }
}

resource "aws_api_gateway_method_response" "hello_OPTIONS" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_OPTIONS.http_method
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "hello_OPTIONS" {
  depends_on = [aws_api_gateway_integration.hello_OPTIONS]
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_OPTIONS.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }
}

resource "aws_api_gateway_method" "hello_GET" {
  depends_on = [aws_lambda_function.hello_GET]
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_GET" {
#  depends_on    = [aws_api_gateway_method.hello_GET, aws_lambda_function.hello_GET]
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_GET.http_method
  integration_http_method = "POST"
  type          = "AWS"
  uri           = aws_lambda_function.hello_GET.invoke_arn
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_integration_response" "hello_GET" {
  depends_on = [aws_api_gateway_integration.hello_GET]
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_GET.http_method
  status_code = aws_api_gateway_method_response.hello_GET.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
  }
}

resource "aws_api_gateway_method_response" "hello_GET" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_GET.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
  }
}

resource "aws_lambda_permission" "hello_GET" {
  statement_id  = "${var.name_prefix}-ApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_GET.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.restapi.id}/*/${aws_api_gateway_method.hello_GET.http_method}${aws_api_gateway_resource.hello.path}"
}