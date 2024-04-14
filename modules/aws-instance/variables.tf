# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


variable "instance_type" {
  description = "Type of EC2 instance to use"
  type        = string
}

variable "subnet_id_public" {
  description = "Subnet ID for bastion host"
}

variable "security_group_id_webtier" {
  description = "Security group ID for webtier"
  type        = list(string)
}

variable "tags" {
  description = "tags"
}

variable "secretARN" {
  description = "secretARN of secret"
}
variable "kms_key_id" {
  description = "Kms key id"
}
