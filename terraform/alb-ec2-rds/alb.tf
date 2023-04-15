resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  internal           = false #falseを指定するとインターネット向け,trueを指定すると内部向け
  idle_timeout       = 60
  # 検証用なのでterraform destoryで削除できるように
  enable_deletion_protection = false
  security_groups = [
    aws_security_group.alb_security_group.id
  ]
  subnets = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id,
  ]
}

# ALBのセキュリティーグループ
resource "aws_security_group" "alb_security_group" {
  name   = "alb_security_group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# リスナー
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# リスナールール
resource "aws_lb_listener_rule" "lb_listener_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 99
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# ALBのターゲットグループ
resource "aws_lb_target_group" "lb_target_group" {
  name                 = "lb_target_group"
  target_type          = "instance"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300
  vpc_id               = aws_vpc.vpc.id
  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

# ターゲットグループをインスタンスに紐づける
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = aws_instance.ec2_instance.id
}
