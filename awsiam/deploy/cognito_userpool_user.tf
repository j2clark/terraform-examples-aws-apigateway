resource "aws_cognito_user" "userpool_user" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = var.username
  password     = var.password

  attributes = {
    email          = "example@example.com"
    email_verified = true
  }
}