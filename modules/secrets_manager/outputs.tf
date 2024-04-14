output "secret_string" {
  description = "the secret string"
  value       = aws_secretsmanager_secret_version.secret.secret_string
}

output "secretARN" {
  description = "arn of secret string"
  value       = aws_secretsmanager_secret_version.secret.arn
}
