resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.get_hello_method,

    aws_api_gateway_integration.hello_lambda_integration,

    aws_api_gateway_gateway_response.cors_4xx,
    aws_api_gateway_gateway_response.cors_5xx,
  ]
  rest_api_id = aws_api_gateway_rest_api.restapi.id

  # To force a redeployment without changing these keys/values, use the -replace option with terraform plan or terraform apply.
  triggers = {
    # redeployment not working if I change method api_key_required value
    # manual redeploy, from console, takes several seconds
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get_hello_method,

      aws_api_gateway_integration.hello_lambda_integration,

      aws_api_gateway_gateway_response.cors_4xx,
      aws_api_gateway_gateway_response.cors_5xx,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v1" {
  depends_on = [
    aws_api_gateway_deployment.deployment,
  ]
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  stage_name    = "v1"

  tags = local.common_tags
}

