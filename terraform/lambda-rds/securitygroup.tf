# lambdaのセキュリティーグループ
resource "aws_security_group" "lambda_security_group" {
  name   = "lambda_security_group"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "lambda_security_group"
  }
}

# 80番ポート開放
resource "aws_security_group_rule" "accept80" {
  security_group_id = aws_security_group.lambda_security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

# アウトバウンドルール
resource "aws_security_group_rule" "lambda_out_all" {
  security_group_id = aws_security_group.lambda_security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
