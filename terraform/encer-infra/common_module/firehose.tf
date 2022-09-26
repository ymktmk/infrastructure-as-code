resource "aws_kinesis_firehose_delivery_stream" "encer_server_firehose" {
  name        = "${var.encer_server}-${var.env_name}-firehose"
  destination = "s3"
  
  s3_configuration {
    role_arn           = aws_iam_role.encer_server_firehose.arn
    bucket_arn         = aws_s3_bucket.encer_server_logs.arn
    buffer_size        = 1
    buffer_interval    = 60
    compression_format = "GZIP"
    # FirehoseのエラーはCloudWatchに送る     
    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.encer_server_firelens.name
      log_stream_name = "kinesis-error"
    }
  }
}

resource "aws_iam_role" "encer_server_firehose" {
  name               = "${var.encer_server}-${var.env_name}-firehose-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["firehose.amazonaws.com"]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "encer_server_firehose" {
  name = "${var.encer_server}-${var.env_name}-firehose-policy"
  role = aws_iam_role.encer_server_firehose.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.encer_server_logs.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.encer_server_logs.bucket}/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "${aws_cloudwatch_log_group.encer_server_firelens.arn}:log-stream:*"
        ]
      }
    ]
  })
}
