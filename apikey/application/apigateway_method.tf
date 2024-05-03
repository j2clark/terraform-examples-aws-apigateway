resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  parent_id = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part = "hello"
}

resource "aws_api_gateway_method" "get_hello_method" {
  depends_on = [
    aws_lambda_function.lambda_get
  ]
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "hello_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.get_hello_method.http_method
  integration_http_method = "POST"
  #  type = "MOCK"
  type = "AWS"
  uri = aws_lambda_function.lambda_get.invoke_arn
}

resource "aws_api_gateway_method_response" "get_hello_response_200" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.get_hello_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "hello_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.get_hello_method.http_method
  status_code = aws_api_gateway_method_response.get_hello_response_200.status_code
}

resource "aws_lambda_permission" "hello_lambda_permission" {
  statement_id  = "${var.name_prefix}-ApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.key.id}/${aws_api_gateway_stage.key_stage_prod.stage_name}/${aws_api_gateway_method.key_gettest.http_method}${aws_api_gateway_resource.key_test.path}"
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.restapi.id}/*/${aws_api_gateway_method.get_hello_method.http_method}${aws_api_gateway_resource.hello.path}"
}

