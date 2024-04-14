provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  cidr = var.vpc_cidr_block
  name = var.vpc_name

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, 2)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, 2)

  # This ensures that the dafault NACL for the VPC has rules only for ipv4

  default_network_acl_ingress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]

  default_network_acl_egress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]
  /*
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
*/
  enable_ipv6 = false

  tags = var.vpc_tags

}
#public subnet security group

resource "aws_security_group" "webtier" {
  vpc_id      = module.vpc.vpc_id
  name        = "webtier"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.vpc_tags

}

module "dbtier_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "dbtier-sg-project-zeus"
  description = "security group for database-tier"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = aws_security_group.webtier.id
      description              = "Allows traffic from web-tier"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = var.vpc_tags
}

module "ec2_instances" {
  source = "./modules/aws-instance"

  instance_type             = var.instance_type
  subnet_id_public          = module.vpc.public_subnets[0]
  security_group_id_webtier = [aws_security_group.webtier.id]
  secretARN                 = module.zeus_secrets_manager.secretARN
  kms_key_id                = module.zeus_kms.kms_key_id
  tags                      = var.vpc_tags
}

module "zeus_kms" {
  source = "./modules/kms"

  tags = var.vpc_tags

}

module "zeus_secrets_manager" {
  source = "./modules/secrets_manager"

  tags       = var.vpc_tags
  kms_key_id = module.zeus_kms.kms_key_id

}

module "rds_postgresql" {
  source = "./modules/rds-postgresql"

  security_group_id_dbtier = module.dbtier_security_group.security_group_id
  subnet_id_private        = module.vpc.private_subnets
  secret_string            = module.zeus_secrets_manager.secret_string
  tags = var.vpc_tags

}

