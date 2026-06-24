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

# VPC pre-created so we can restore RDS here immediately during a DR event
module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name
  cidr                 = "10.1.0.0/16"
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
  tags                 = local.tags
}

# DR vault — receives cross-region copies from the primary backup plan daily
module "backup_vault" {
  source = "../../modules/backup"

  vault_name              = "${local.name}-vault"
  create_plan             = false
  dr_vault_arn            = ""
  protected_resource_arns = []
  tags                    = local.tags
}

# DB subnet group pre-created so an RDS restore can reference it immediately
resource "aws_db_subnet_group" "dr_restore" {
  name       = "${local.name}-restore-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(local.tags, { Name = "${local.name}-restore-subnet-group" })
}
