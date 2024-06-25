# Terraform OPTIONS has a bug

Creating an OPTIONS method in Terraform is tricky

Get it wrong and CORS is broke. The Method Test in API Gateway returns a 500 parsing exception

It took me a long time to figure out that I needed to not only to declare a request_template for OPTIONS integration, but the status code MUST be an integer

```terraform
resource "aws_api_gateway_integration" "example_OPTIONS" {
  depends_on = [aws_api_gateway_method.users_OPTIONS]
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = aws_api_gateway_method.users_OPTIONS.http_method
  type          = "MOCK"
  request_templates = {
    "application/json" = <<JSON
{
    "statusCode": 200
}
JSON
  }
}
```

Another issue is the order of creation. Following this order using dependencies seems to work:

1. resource "aws_api_gateway_method" "example_OPTIONS"
2. resource "aws_api_gateway_integration" "example_OPTIONS" {depends_on = [aws_api_gateway_method.example_OPTIONS]}
3. resource "aws_api_gateway_integration_response" "example_OPTIONS" {depends_on = [aws_api_gateway_integration.example_OPTIONS]}
4. resource "aws_api_gateway_method_response" "example_OPTIONS" {depends_on = [aws_api_gateway_integration_response.example_OPTIONS]}
