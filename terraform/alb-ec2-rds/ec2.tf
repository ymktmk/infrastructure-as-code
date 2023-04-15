resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.latest_ami.image_id
  instance_type = "t2.micro"
  # パブリックサブネットに配置
  subnet_id              = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = aws_key_pair.key_pair.id
  user_data              = file("script.sh")
  tags = {
    Name = "ec2_instance"
  }
}

# EC2のセキュリティーグループ
resource "aws_security_group" "ec2_security_group" {
  name   = "ec2_security_group"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "ec2_security_group"
  }
}

# 80番ポート開放
resource "aws_security_group_rule" "accept80" {
  security_group_id = aws_security_group.ec2_security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

# 22番ポート開放
resource "aws_security_group_rule" "accept22" {
  security_group_id = aws_security_group.ec2_security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# アウトバウンドルール
resource "aws_security_group_rule" "ec2_out_all" {
  security_group_id = aws_security_group.ec2_security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
