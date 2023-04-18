resource "aws_apprunner_service" "hair_wellness" {
  service_name = "hair-wellness"

  source_configuration {
    auto_deployments_enabled = false
    authentication_configuration {
      access_role_arn = aws_iam_role.ecr_access_role.arn
    }
    image_repository {
      image_configuration {
        start_command = "./main"
        port          = "8080"
        runtime_environment_variables = {
          ENV_NAME              = "prd"
          POSTGRES_DSN          = var.postgres_dsn,
          CUSTOMER_ACCESS_TOKEN = var.customer_access_token,
          SALON_ACCESS_TOKEN    = var.salon_access_token
        }
      }
      image_repository_type = "ECR"
      image_identifier      = "${aws_ecr_repository.hair_wellness.repository_url}:latest"
    }
  }

  health_check_configuration {
    protocol = "HTTP"
    path     = "/health"
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
    cpu               = "1024"
    memory            = "2048"
  }
}
