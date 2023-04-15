# fluentbit log
resource "aws_cloudwatch_log_group" "encer_server_firelens" {
  name = "/${var.encer_server}/${var.env_name}/firelens"
}

# firehose error
resource "aws_cloudwatch_log_stream" "encer_server_kinesis" {
  name           = "kinesis-error"
  log_group_name = aws_cloudwatch_log_group.encer_server_firelens.name
}
