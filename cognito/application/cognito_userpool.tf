#we deploy as part
resource "aws_cognito_user_pool" "userpool" {
  name = "${var.name_prefix}-userpool"
  auto_verified_attributes = ["email"]
  email_verification_message = "Your verification code is {####}"
  email_verification_subject = "Your verification code"
  mfa_configuration = "OFF"
  password_policy {
    minimum_length = 6
    require_lowercase = "false"
    require_numbers = "false"
    require_symbols = "false"
    require_uppercase = "false"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name                = "email"
    required = true
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }
  username_configuration {
    case_sensitive = false
  }
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  depends_on = [aws_cognito_user_pool.userpool]
  name         = "${var.name_prefix}-userpool-webclient"
  user_pool_id = aws_cognito_user_pool.userpool.id
  refresh_token_validity = 5
  token_validity_units {
    refresh_token = "days"
  }

  explicit_auth_flows = [
    ## enable the authentication tokens to be refreshed
    "ALLOW_REFRESH_TOKEN_AUTH",
    ## enable user authentication by username(in our case email) and password
    "ALLOW_USER_PASSWORD_AUTH",
    ## enable user authentication with credentials created by the admin
#    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}


output "application_client_id" {
  value = aws_cognito_user_pool_client.userpool_client.id
}

output "cognito_username" {
  value = "example"
}

output "cognito_password" {
  value = "example"
}