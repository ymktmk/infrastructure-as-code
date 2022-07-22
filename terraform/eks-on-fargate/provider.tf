provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  required_version = "~> 1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
