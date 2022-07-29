provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  # 1.2.6 
  # 1.1.7
  required_version = "1.2.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 4.7.0
      version = "4.10.0"
    }
  }
}
