resource "aws_api_gateway_rest_api" "restapi" {
  name        = var.name_prefix
  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }

  tags = local.common_tags
}

#resource "aws_cloudwatch_log_group" "loggroup" {
#  #  this name pattern is fixed by API Gateway
#  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.restapi.id}/${aws_api_gateway_stage.v1.stage_name}"
#  retention_in_days = 3
#  # ... potentially other configuration ...
#
#  tags = local.common_tags
#}

resource "aws_api_gateway_authorizer" "aws_cognito_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  provider_arns = [
    aws_cognito_user_pool.userpool.arn
  ]
}