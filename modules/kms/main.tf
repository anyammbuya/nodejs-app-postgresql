# Section for KMS key
resource "aws_kms_key" "RDScredentialKey" {
  description             = "Key for encrypting RDS credentials"
  deletion_window_in_days = var.deletion_days
  enable_key_rotation     = true




  policy = file("modules/json-policy/kms-access-policy.json")

  tags = var.tags
}

# Section for KMS key alias

resource "aws_kms_alias" "RDScredentialKey" {
  name          = "alias/ec2-session"
  target_key_id = aws_kms_key.RDScredentialKey.key_id
}