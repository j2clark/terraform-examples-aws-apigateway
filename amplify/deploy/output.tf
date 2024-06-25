output "REGION" {
  value = local.region
}

output "USER_POOL_ID" {
  value = aws_cognito_user_pool.userpool.id
}
output "APP_CLIENT_ID" {
  value = aws_cognito_user_pool_client.userpool_client.id
}

output "IDENTITY_POOL_ID" {
  value = aws_cognito_identity_pool.identity_pool.id
}
