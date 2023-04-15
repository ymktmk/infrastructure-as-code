terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# 以下二つは先に作成しておき、後にbackendのコメントアウトを外す
resource "aws_s3_bucket" "encer_terraform_state" {
  bucket = "encer-stg-terraform-state"

  lifecycle {
    prevent_destroy = true
  }
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "encer_terraform_state_lock" {
  name           = "encer-stg-terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
