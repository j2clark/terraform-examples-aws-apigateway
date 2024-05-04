resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  parent_id = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part = "hello"
}

## This is a BUG in terraform aws - the OPTION method is malformed and breaks API
## For now we manually add this in the Console
#resource "aws_api_gateway_method" "hello_options" {
#  rest_api_id   = aws_api_gateway_rest_api.restapi.id
#  resource_id   = aws_api_gateway_resource.hello.id
#  http_method   = "OPTIONS"
#  authorization = "NONE"
#}
#
#resource "aws_api_gateway_integration" "hello_options_integration" {
#  rest_api_id   = aws_api_gateway_rest_api.restapi.id
#  resource_id   = aws_api_gateway_resource.hello.id
#  http_method   = aws_api_gateway_method.hello_options.http_method
#  type          = "MOCK"
#  passthrough_behavior = "WHEN_NO_TEMPLATES"
#  depends_on = [aws_api_gateway_method.hello_options]
#}
#
#resource "aws_api_gateway_integration_response" "hello_options_integration_response" {
#  rest_api_id   = aws_api_gateway_rest_api.restapi.id
#  resource_id   = aws_api_gateway_resource.hello.id
#  http_method   = aws_api_gateway_method.hello_options.http_method
#  status_code   = aws_api_gateway_method_response.hello_options_200.status_code
#  response_parameters = {
#    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
#    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
#    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
#    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
#  }
#  response_templates = {
#    "application/json": "Empty"
#  }
#  depends_on = [aws_api_gateway_integration.hello_options_integration, aws_api_gateway_method_response.hello_options_200]
#}
#
#resource "aws_api_gateway_method_response" "hello_options_200" {
#  rest_api_id   = aws_api_gateway_rest_api.restapi.id
#  resource_id   = aws_api_gateway_resource.hello.id
#  http_method   = aws_api_gateway_method.hello_options.http_method
#  status_code   = "200"
#  response_models = {
#    "application/json" = "Empty"
#  }
#  response_parameters = {
#    "method.response.header.Access-Control-Allow-Headers" = true,
#    "method.response.header.Access-Control-Allow-Methods" = true,
#    "method.response.header.Access-Control-Allow-Origin" = true,
#    "method.response.header.Access-Control-Allow-Credentials" = true
#  }
#  depends_on = [aws_api_gateway_method.hello_options]
#}

resource "aws_api_gateway_method" "get_hello_method" {
  depends_on = [
    aws_lambda_function.lambda_get
  ]
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_lambda_integration" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.get_hello_method.http_method
  integration_http_method = "POST"
  type          = "AWS"
  uri           = aws_lambda_function.lambda_get.invoke_arn
  depends_on    = [aws_api_gateway_method.get_hello_method, aws_lambda_function.lambda_get]
}

resource "aws_api_gateway_integration_response" "hello_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.get_hello_method.http_method
  status_code = aws_api_gateway_method_response.get_hello_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
  }
  depends_on = [aws_api_gateway_integration.hello_lambda_integration, aws_api_gateway_method_response.get_hello_response_200]
}

resource "aws_api_gateway_method_response" "get_hello_response_200" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.get_hello_method.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
  }
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.get_hello_method]
}

resource "aws_lambda_permission" "hello_lambda_permission" {
  statement_id  = "${var.name_prefix}-ApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.restapi.id}/*/${aws_api_gateway_method.get_hello_method.http_method}${aws_api_gateway_resource.hello.path}"
}