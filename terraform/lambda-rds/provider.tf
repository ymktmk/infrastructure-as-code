provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}
