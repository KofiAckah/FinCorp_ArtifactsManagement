terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name = "${var.project}-${var.environment}"
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  tags                 = local.tags
}

module "jenkins" {
  source = "../../modules/jenkins"

  name              = local.name
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_ids[0]
  instance_type     = var.jenkins_instance_type
  key_name          = var.key_pair_name
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  tags              = local.tags
}

module "codeartifact" {
  source = "../../modules/codeartifact"

  domain_name = var.project
  tags        = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  name = "${var.project}/finance-tracker"
  tags = local.tags
}

module "rds" {
  source = "../../modules/rds"

  name                      = local.name
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  allowed_security_group_id = module.jenkins.security_group_id
  db_name                   = "fincorp"
  db_username               = "fincorp_user"
  db_password               = var.db_password
  instance_class            = var.rds_instance_class
  tags                      = local.tags
}

module "backup" {
  source = "../../modules/backup"

  vault_name              = "${local.name}-vault"
  create_plan             = true
  dr_vault_arn            = var.dr_vault_arn
  protected_resource_arns = [module.rds.db_arn]
  tags                    = local.tags
}
