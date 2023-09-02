#######################
# CloudFront 署名つきURL
#######################
resource "aws_s3_bucket" "encer_images" {
  bucket = "encer"
  versioning {
    enabled = false
  }
}

# Terraform Applyでエラーが出る
# https://zenn.dev/devcamp/articles/39ce7fd0272926
resource "aws_s3_bucket_acl" "encer_images" {
  bucket = aws_s3_bucket.encer_images.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "encer_images" {
  bucket = aws_s3_bucket.encer_images.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : { "AWS" : "${aws_cloudfront_origin_access_identity.origin_access.iam_arn}" },
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
        ],
        "Resource" : [
          "${aws_s3_bucket.encer_images.arn}",
          "${aws_s3_bucket.encer_images.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "encer_images" {
  bucket                  = aws_s3_bucket.encer_images.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

########################
# CloudFront ALB and S3
########################
resource "aws_s3_bucket" "web_app" {
  bucket = "ymktmk-web-app"
}

resource "aws_s3_bucket_acl" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "web_app" {
  bucket                  = aws_s3_bucket.web_app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_cloudfront_origin_access_identity.web_app.iam_arn}"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.web_app.arn}/*"
      }
    ]
  })
}
