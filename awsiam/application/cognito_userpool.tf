#we deploy as part
resource "aws_cognito_user_pool" "userpool" {
  name = "${var.name_prefix}-userpool"
  mfa_configuration = "OFF"
  password_policy {
    minimum_length = 6
    require_lowercase = "false"
    require_numbers = "false"
    require_symbols = "false"
    require_uppercase = "false"
  }

  tags = local.common_tags
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.userpool.id
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows = [
    ## enable the authentication tokens to be refreshed
    "ALLOW_REFRESH_TOKEN_AUTH",
    ## enable user authentication by username(in our case email) and password
    "ALLOW_USER_PASSWORD_AUTH",
  ]
}

