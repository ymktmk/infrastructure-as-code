resource "aws_acm_certificate" "cert" {
  domain_name       = "frontend.jp"
  validation_method = "DNS"
  provider          = aws.virginia
  lifecycle {
    create_before_destroy = false
  }
  tags = {
    Name = "acm"
  }
}
