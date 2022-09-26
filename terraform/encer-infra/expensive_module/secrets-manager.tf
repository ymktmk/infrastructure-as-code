resource "aws_secretsmanager_secret" "encer_server_mysql_dsn" {
  name                           = "${var.encer_server}-${var.env_name}/mysql-dsn"
  force_overwrite_replica_secret = false
  # 後で変更
  rotation_rules {
    automatically_after_days = 0
  }
  lifecycle {
    ignore_changes = [
      replica,
    ]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws secretsmanager delete-secret --secret-id encer-server-stg/mysql-dsn --force-delete-without-recovery"
  }
}

resource "aws_secretsmanager_secret" "encer_server_stripe_secret" {
  name                           = "${var.encer_server}-${var.env_name}/stripe-secret"
  force_overwrite_replica_secret = false
  rotation_rules {
    automatically_after_days = 0
  }
  lifecycle {
    ignore_changes = [
      replica,
    ]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws secretsmanager delete-secret --secret-id encer-server-stg/stripe-secret --force-delete-without-recovery"
  }
}
