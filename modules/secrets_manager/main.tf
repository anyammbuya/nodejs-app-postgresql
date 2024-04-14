resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  kms_key_id              = var.kms_key_id
  name                    = "rds_credentials"
  description             = "RDS Admin password"
  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = random_password.master_password.result
}