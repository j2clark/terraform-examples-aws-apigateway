resource "aws_api_gateway_rest_api" "restapi" {
  name = var.name_prefix
  endpoint_configuration {
    types = [
#      "EDGE",
      "REGIONAL"
    ]
  }

  tags = local.common_tags
}

resource "aws_api_gateway_gateway_response" "cors_4xx" {
  rest_api_id         = aws_api_gateway_rest_api.restapi.id
  response_type       = "DEFAULT_4XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "gatewayresponse.header.Access-Control-Allow-Origin" = local.cors_origin
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }
}

resource "aws_api_gateway_gateway_response" "cors_5xx" {
  rest_api_id         = aws_api_gateway_rest_api.restapi.id
  response_type       = "DEFAULT_5XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "gatewayresponse.header.Access-Control-Allow-Origin" = local.cors_origin
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }
}
