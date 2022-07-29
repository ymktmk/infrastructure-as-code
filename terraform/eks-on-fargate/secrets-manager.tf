# resource "aws_secretsmanager_secret" "password" {
#   name                           = "aws/password"
#   force_overwrite_replica_secret = false
#   lifecycle {
#     ignore_changes = [
#       replica,
#     ]
#   }
# }
