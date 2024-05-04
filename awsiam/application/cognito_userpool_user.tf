resource "aws_cognito_user" "userpool_user" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = local.username
  password     = local.password

  attributes = {
    email          = "example@example.com"
    email_verified = true
  }
}