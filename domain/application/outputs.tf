#output "api_gateway_id" {
#  value = aws_api_gateway_rest_api.restapi.id
#}

output "api_domain" {
  value = "https://${aws_api_gateway_domain_name.api_domain.domain_name}"
}