resource "aws_acm_certificate" "cert" {
  domain_name       = "image.${var.encer_domain}"
  validation_method = "DNS"
  provider          = aws.virginia
  lifecycle {
    create_before_destroy = false
  }
  tags = {
    Name = "encer-acm"
  }
}
