## RDS *セキュリティの観点からRDS本体に関してはTerraformで管理していない
resource "aws_db_subnet_group" "encer_server_db_subnet_group" {
  name = "${var.encer_server}-${var.env_name}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]
  tags = {
    Name = "${var.encer_server}-${var.env_name}-db-subnet-group"
  }
}

resource "aws_security_group" "encer_server_rds_security_group" {
  name   = "${var.encer_server}-${var.env_name}-rds-sg"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.encer_server}-${var.env_name}-rds-sg"
  }
}

resource "aws_security_group_rule" "accept3306" {
  security_group_id = aws_security_group.encer_server_rds_security_group.id
  type              = "ingress"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
}

resource "aws_security_group_rule" "rds_out_all" {
  security_group_id = aws_security_group.encer_server_rds_security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
