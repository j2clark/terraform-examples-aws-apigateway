resource "aws_api_gateway_domain_name" "api_domain" {
#  Because certs are created and validated as part of this configuration,
#  we reference the aws_acm_certificate_validation instead of the certificate_arn,
#  ensuring validation is fully completed before creating domain
  certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
#  certificate_arn = aws_acm_certificate.ssl_certificate.arn
  domain_name     = "api.${var.domain}"
}

resource "aws_api_gateway_base_path_mapping" "example" {
  api_id      = aws_api_gateway_rest_api.restapi.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api_domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.cloudfront_zone_id
  }
}