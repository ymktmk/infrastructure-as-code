terraform {
  required_version = "1.2.6"

  # S3で管理する
  backend "s3" {
    bucket         = "encer-stg-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "encer-stg-terraform-state-lock"
  }
}
