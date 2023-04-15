resource "aws_route53_zone" "primary" {
  name          = var.encer_domain
  force_destroy = false
}

# CloudFront
resource "aws_route53_record" "image" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "image.${var.encer_domain}"
  type    = "CNAME"
  ttl     = 600
  records = [aws_cloudfront_distribution.cloudfront_distribution.domain_name]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 300
  zone_id         = aws_route53_zone.primary.zone_id
}


