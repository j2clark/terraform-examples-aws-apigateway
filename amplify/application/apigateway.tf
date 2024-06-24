resource "aws_api_gateway_rest_api" "restapi" {
  name        = var.name_prefix
  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }

  tags = local.common_tags
}