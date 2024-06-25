# https://stackoverflow.com/questions/48451755/terraform-definition-of-cognito-identity-pool-auth-unauth-roles

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = "${local.name_prefix}-idpool"

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.userpool_client.id
    provider_name           = aws_cognito_user_pool.userpool.endpoint
  }

  tags = local.common_tags
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  roles = {
    authenticated   = aws_iam_role.authenticated.arn
#    unauthenticated = aws_iam_role.unauthenticated.arn
  }
}