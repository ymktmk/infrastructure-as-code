resource "aws_route53_zone" "primary" {
  name          = "stg.encer.jp"
  force_destroy = false
}

# CloudFront
resource "aws_route53_record" "image" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "image.stg.encer.jp"
  type    = "CNAME"
  ttl     = 600
  records = [aws_cloudfront_distribution.cloudfront_distribution.domain_name]
}

# SES
resource "aws_route53_record" "stg" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "stg.encer.jp"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.encer.verification_token]
}

# ACMのドメイン検証の際にCNAMEをRoute53に追加する
# ＊Google Domains側のCNAMEに追加してから「terraform apply」し直してACM, SESのドメイン認証を通さなければならない
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
  ttl             = "300"
  zone_id         = aws_route53_zone.primary.zone_id
}

