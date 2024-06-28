resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.get_hello_method,
    aws_api_gateway_integration.hello_lambda_integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.restapi.id

  # To force a redeployment without changing these keys/values, use the -replace option with terraform plan or terraform apply.
  triggers = {
    # redeployment not working if I change method api_key_required value
    # manual redeploy, from console, takes several seconds
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get_hello_method,
      aws_api_gateway_integration.hello_lambda_integration,
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

resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}


resource "aws_api_gateway_usage_plan" "usageplan" {
  name = "${var.name_prefix}-usageplan"

  api_stages {
    api_id = aws_api_gateway_rest_api.restapi.id
    stage  = aws_api_gateway_stage.v1.stage_name
  }

  tags = local.common_tags
}

resource "aws_api_gateway_api_key" "key_apikey" {
  name = "${var.name_prefix}-apikey"
}

resource "aws_api_gateway_usage_plan_key" "key_usageplan_apikey" {
  key_id        = aws_api_gateway_api_key.key_apikey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usageplan.id
}

#output "api_id" {
#  value = aws_api_gateway_rest_api.restapi.id
#}
#
#output "apikey_name" {
#  value = aws_api_gateway_api_key.key_apikey.name
#}
#
#output "get_hello" {
#  value = "https://${aws_api_gateway_rest_api.restapi.id}.execute-api.${local.region}.amazonaws.com/${aws_api_gateway_stage.v1.stage_name}/${aws_api_gateway_resource.hello.path}"
#}