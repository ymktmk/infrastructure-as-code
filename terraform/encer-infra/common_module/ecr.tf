resource "aws_ecr_repository" "ecr_repository" {
  name                 = "${var.encer_server}/${var.env_name}/api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "encer_server_fluentbit" {
  name = "${var.encer_server}/${var.env_name}/fluentbit"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
