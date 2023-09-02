#######################
# CloudFront 署名つきURL
#######################
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases             = ["image.stg.encer.jp"]
  default_root_object = "index.html"
  enabled             = true
  retain_on_delete    = false
  wait_for_deployment = true

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    trusted_key_groups = [
      aws_cloudfront_key_group.cloudfront_key_group.id
    ]
    compress               = true
    smooth_streaming       = false
    target_origin_id       = aws_s3_bucket.encer_images.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name = aws_s3_bucket.encer_images.bucket_domain_name
    origin_id   = aws_s3_bucket.encer_images.bucket_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access" {
  comment = aws_s3_bucket.encer_images.bucket_domain_name
}

resource "aws_cloudfront_public_key" "cloudfront_public_key" {
  name        = "public_key"
  encoded_key = file("../public_key.pem")
}

resource "aws_cloudfront_key_group" "cloudfront_key_group" {
  name  = "key_group"
  items = [aws_cloudfront_public_key.cloudfront_public_key.id]
}

########################
# CloudFront ALB and S3
########################
resource "aws_cloudfront_origin_access_identity" "web_app" {
  comment = "ymktmk-web-app"
}

resource "aws_cloudfront_distribution" "web_app" {
  retain_on_delete = true

  # ALB
  origin {
    domain_name = "ここにALBのDNS名を入れる"
    origin_id   = "ALBOriginWear2WebPreview"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # S3
  origin {
    domain_name = aws_s3_bucket.web_app.bucket_domain_name
    origin_id   = "S3OriginWebAssets"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_app.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = false
  http_version    = "http2"

  aliases = ["ここにドメイン名を入れる"]

  # S3
  ordered_cache_behavior {
    path_pattern     = "/public/*"
    cache_policy_id  = "Managed-CachingOptimized"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3OriginWebAssets"

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # ALB
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALBOriginWebApp"

    viewer_protocol_policy = "https-only"

    # 全てのリクエストをALBに転送する
    forwarded_values {
      headers      = ["*"]
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ACM
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.web_app.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }

  lifecycle {
    prevent_destroy = true
  }
}
