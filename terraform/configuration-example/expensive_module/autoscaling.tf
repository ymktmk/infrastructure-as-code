resource "aws_launch_configuration" "encer_server_launch_config" {
  name                 = "${var.encer_server}-${var.env_name}-cluster"
  image_id             = data.aws_ami.ami.id
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_role.name
  security_groups      = [aws_security_group.security_group.id]
  user_data            = file("../stg/userdata.sh")
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.key_pair.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "encer_server_autoscaling_group" {
  name                      = "${var.encer_server}-${var.env_name}-autoscaling-group"
  vpc_zone_identifier       = [var.public_subnet_1a_id]
  launch_configuration      = aws_launch_configuration.encer_server_launch_config.name
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  health_check_grace_period = 0
  protect_from_scale_in     = true
  lifecycle {
    create_before_destroy = true
  }
  # EC2がrunning以外の時に切り離す
  health_check_type = "EC2"
}
