# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  /*
  cloud {
    organization = "KingstonLtd"
    workspaces {

      name = "wsp2"
    }
  }
  */

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.43"
    }

  }

  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-stacksimplifyjk"
    key    = "dev2/terraform.tfstate"
    region = "us-east-2"

  }

  required_version = "~> 1.2"
}


