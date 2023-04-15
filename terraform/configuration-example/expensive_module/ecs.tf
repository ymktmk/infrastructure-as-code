resource "aws_ecs_cluster" "cluster" {
  name = "${var.encer_server}-${var.env_name}-cluster"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.encer_server}-${var.env_name}"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["EC2"]
  # ロールの違い https://dev.classmethod.jp/articles/ecs_fargate_iamrole/
  # https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task-iam-roles.html
  task_role_arn = aws_iam_role.ecs_task_exception_role.arn # Firehose, CloudWatch
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
  execution_role_arn = aws_iam_role.ecs_task_exception_role.arn # ECR, SecretsManager etc
  volume {
    host_path = "/var/www/.cache"
    name      = "cache"
  }
  container_definitions = jsonencode(
    [
      {
        name              = "${var.encer_server}-${var.env_name}"
        command           = ["/main"]
        cpu               = 128
        memory            = 256
        memoryReservation = 128
        essential         = true
        image             = "009554248005.dkr.ecr.ap-northeast-1.amazonaws.com/encer-server/stg/api:latest"
        logConfiguration = {
          logDriver = "awsfirelens"
        }
        mountPoints = [
          {
            containerPath = "/var/www/.cache"
            sourceVolume  = "cache"
          }
        ]
        portMappings = [
          {
            containerPort = 443
            hostPort      = 443
            protocol      = "tcp"
          },
          {
            containerPort = 80
            hostPort      = 80
            protocol      = "tcp"
          },
          {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          },
        ]
        environment = [
          { "name" : "ENV_NAME", "value" : "staging" },
          { "name" : "DOMAIN", "value" : "api.${var.encer_domain}" },
          # FIREBASE_AUTH_REST_API_KEYはstagingのみ使用
          { "name" : "FIREBASE_AUTH_REST_API_KEY", "value" : "AIzaSyCvgR_fxQQw8V-8OOCZQDYG4A-h21VNvWE" },
          { "name" : "GOOGLE_APPLICATION_CREDENTIALS", "value" : "/go/src/go-app/firebase_auth.json" }
        ]
        secrets = [
          {
            "name" : "MYSQL_DSN",
            "valueFrom" : "${aws_secretsmanager_secret.encer_server_mysql_dsn.arn}"
          },
          {
            "name" : "STRIPE_SECRET",
            "valueFrom" : "${aws_secretsmanager_secret.encer_server_stripe_secret.arn}"
          }
        ]
      },
      {
        name              = "log-router"
        memoryReservation = 50
        essential         = true
        image             = "009554248005.dkr.ecr.ap-northeast-1.amazonaws.com/encer-server/stg/fluentbit:latest"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/encer-server/stg/firelens"
            awslogs-region        = "ap-northeast-1"
            awslogs-stream-prefix = "golang-sidecar"
          }
        }
        firelensConfiguration = {
          type = "fluentbit"
          options = {
            config-file-type  = "file"
            config-file-value = "/fluent-bit/etc/extra.conf"
          }
        }
      }
    ]
  )
}

resource "aws_ecs_service" "service" {
  name                               = "${var.encer_server}-${var.env_name}-service"
  cluster                            = aws_ecs_cluster.cluster.id
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  desired_count                      = 1
  force_new_deployment               = true
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.task_definition.arn
}

## ECS Security Group
resource "aws_security_group" "security_group" {
  name   = "${var.encer_server}-${var.env_name}-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.encer_server}-${var.env_name}-sg"
  }
}

resource "aws_security_group_rule" "accept8080" {
  security_group_id = aws_security_group.security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
}

resource "aws_security_group_rule" "accept443" {
  security_group_id = aws_security_group.security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "accept80" {
  security_group_id = aws_security_group.security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "accept22" {
  security_group_id = aws_security_group.security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# Task Exception Role
resource "aws_iam_role" "ecs_task_exception_role" {
  name = "ecs_task_exception_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["ecs-tasks.amazonaws.com"]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_exception_role_policy" {
  name = "ecs_task_exception_role_policy"
  role = aws_iam_role.ecs_task_exception_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "firehose:PutRecordBatch"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

# ECS Instance Role
resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["ec2.amazonaws.com"]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name = "ecs_instance_role_policy"
  role = aws_iam_role.ecs_instance_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAddresses",
          "ec2:AllocateAddress",
          "ec2:DescribeInstances",
          "ec2:AssociateAddress",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:*",
          "route53domains:*",
        ],
        "Resource" : "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:CreateHealthCheck"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_full_access_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_build_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

## ECS Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "encer"
  public_key = file("../../encer.pub")
}

## ECS AMI
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}
