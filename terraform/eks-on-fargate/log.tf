resource "aws_s3_bucket" "nginx_logs" {
  bucket = "ymktmk-nginx-logs"
  # 検証のため   
  force_destroy = true
}

resource "aws_s3_bucket_policy" "nginx_logs" {
  bucket = aws_s3_bucket.nginx_logs.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "delivery.logs.amazonaws.com",
            "logs.ap-northeast-1.amazonaws.com"
          ]
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "${aws_s3_bucket.nginx_logs.arn}"
      }
    ]
  })
}

resource "aws_iam_role" "nginx_logs" {
  name = "wear2_auth_logs"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Effect" : "Allow",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "009554248005"
          }
        }
      }
    ]
  })
  managed_policy_arns = [
    aws_iam_policy.nginx_logs.arn,
  ]
}

resource "aws_iam_policy" "nginx_logs" {
  name = "nginx_logs"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [
          "${aws_s3_bucket.nginx_logs.arn}"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.nginx_logs.arn}/*"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "glue:GetTable",
          "glue:GetTableVersion",
          "glue:GetTableVersions"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "nginx_nginx" {
  name        = "nginx_nginx"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.nginx_logs.arn
    bucket_arn          = aws_s3_bucket.nginx_logs.arn
    buffer_interval     = 300
    buffer_size         = 64
    compression_format  = "UNCOMPRESSED"
    prefix              = "eks/nginx/nginx/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{timestamp:HH}/"
    error_output_prefix = "eks/nginx/nginx/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{timestamp:HH}/!{firehose:error-output-type}"

    cloudwatch_logging_options {
      enabled = false
    }

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }
      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
      # FirehoseからS3へ転送する際にGlueにて変換する
      schema_configuration {
        catalog_id    = "009554248005"
        database_name = aws_glue_catalog_table.nginx_nginx.database_name
        table_name    = aws_glue_catalog_table.nginx_nginx.name
        role_arn      = aws_iam_role.nginx_logs.arn
        region        = "ap-northeast-1"
        version_id    = "LATEST"
      }
    }
  }
}

resource "aws_glue_catalog_database" "nginx" {
  name       = "nginx"
  catalog_id = "009554248005"
}

resource "aws_glue_catalog_table" "nginx_nginx" {
  name          = "nginx_nginx"
  database_name = "nginx"
  catalog_id    = "009554248005"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL                           = "TRUE"
    "projection.enabled"               = "true"
    "projection.logdate.type"          = "date"
    "projection.logdate.interval"      = "1"
    "projection.logdate.format"        = "yyyy/MM/dd/HH"
    "projection.logdate.range"         = "2022/01/01/00,NOW"
    "projection.logdate.interval.unit" = "HOURS"
    "typeOfData"                       = "file"
    "storage.location.template"        = "s3://${aws_s3_bucket.nginx_logs.id}/eks/nginx/nginx/$${day}/"
  }
  storage_descriptor {
    location      = "s3://${aws_s3_bucket.nginx_logs.id}/eks/nginx/nginx/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = 1
      }
    }
    columns {
      name = "log"
      type = "string"
    }
    columns {
      name = "kubernetes"
      type = "string"
    }
  }
  partition_keys {
    name = "day"
    type = "string"
  }
}
