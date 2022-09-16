resource "aws_s3_bucket" "encer_images" {
  bucket = "encer"
  versioning {
    enabled = false
  }
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

resource "aws_s3_bucket_acl" "encer_images" {
  bucket = aws_s3_bucket.encer_images.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "encer_images" {
  bucket                  = aws_s3_bucket.encer_images.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
