# 変数定義
variable "aws_default_region" {
  default = "ap-northeast-1"
}

variable "aws_account_id" {
  type = string
}

variable "encer_domain" {
  type = string
}

variable "env_name" {
  type = string
}

variable "encer_server" {
  type    = string
  default = "encer-server"
}
