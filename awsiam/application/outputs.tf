#output "api_gateway_id" {
#  value = aws_api_gateway_rest_api.restapi.id
#}

output "clientParameters" {
  value = {
    REGION = local.region,
    ACCOUNT_ID = local.account_id,
    API_ID = aws_api_gateway_rest_api.restapi.id,
    # resource starts wih /
#    API_ENDPOINT = "/${aws_api_gateway_stage.v1.stage_name}${aws_api_gateway_resource.hello.path}",
    CLIENT_ID = aws_cognito_user_pool_client.userpool_client.id,
    USERPOOL_URL = aws_cognito_user_pool.userpool.endpoint,
    IDENTITYPOOL_ID = aws_cognito_identity_pool.identity_pool.id,
    USERNAME = local.username,
    PASSWORD = local.password
  }

}