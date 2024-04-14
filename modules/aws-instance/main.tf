# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

// NOW create ec2 instance profile with IAM role for access to secrets manager

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns =[aws_iam_policy.secretsM_policy.arn]
}

#get the policies

data "aws_iam_policy_document" "secrets_and_kms_access" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]
    resources = [
      "${var.secretARN}",
      "${var.kms_key_id}", 
    ]
  }
}


resource "aws_iam_policy" "secretsM_policy" {
  name        = "ec2SecretsManagerAccess"
  description = "A policy for ec2 to access secrets manager and decrypt secret"
  policy      = data.aws_iam_policy_document.secrets_and_kms_access.json
  tags        = var.tags
}


#Attach role to an instance profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "zeus-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

// NOW create ec2 instance
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("${path.module}/mykey.pub")
}


resource "aws_instance" "bastion" {

  ami                          = "ami-0b8b44ec9a8f90422"
  instance_type                = var.instance_type

  subnet_id                    = var.subnet_id_public
  #associate_public_ip_address = true
  vpc_security_group_ids       = var.security_group_id_webtier

  key_name                     = aws_key_pair.mykeypair.key_name
  iam_instance_profile         = aws_iam_instance_profile.ec2_profile.name
  tags                         = var.tags


}

