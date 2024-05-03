output "api_gateway_id" {
  value = aws_api_gateway_rest_api.restapi.id
}

output "apikey_name" {
  value = aws_api_gateway_api_key.key_apikey.name
}