terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }

  cloud {
    organization = "dakual"
    workspaces {
      tags = ["ecs"]
    }
  }

  required_version = ">= 1.3.6"
}

provider "aws" {
  region  = local.var.region
}

locals {
    workspace_path = "${path.module}/variables/${terraform.workspace}.yaml" 
    defaults       = file("${path.module}/variables/default.yaml")

    workspace = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})
    var       = merge(
        yamldecode(local.defaults),
        yamldecode(local.workspace)
    )
}

module "iam" {
  source              = "./core/iam"
  name                = local.var.name
  environment         = local.var.environment
}

module "r53" {
  source              = "./core/r53"
  name                = local.var.name
  environment         = local.var.environment
  domain              = local.var.domain
  alb_zone_id         = module.alb.alb_zone_id
  alb_dns_name        = module.alb.alb_dns_name
}

module "rds" {
  source              = "./core/rds"
  name                = local.var.name
  environment         = local.var.environment
  db_name             = local.var.rds.db_name
  db_username         = local.var.rds.db_username
  rds_security_groups = [ module.vpc.vpc_sg_rds ]
  rds_subnets         = module.vpc.vpc_private_subnets
}

module "vpc" {
  source              = "./core/vpc"
  name                = local.var.name
  cidr                = local.var.cidr
  private_subnets     = local.var.private_subnets
  public_subnets      = local.var.public_subnets
  availability_zones  = local.var.availability_zones
  environment         = local.var.environment
}

module "efs" {
  source              = "./core/efs"
  name                = local.var.name
  private_subnets     = module.vpc.vpc_private_subnets
  vpc_id              = module.vpc.vpc_id
  environment         = local.var.environment
}

module "alb" {
  source              = "./core/alb"
  name                = local.var.name
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.vpc_public_subnets
  environment         = local.var.environment
  alb_security_groups = [ module.vpc.vpc_sg_alb ]
  alb_tls_cert_arn    = module.r53.r53_tls_certificate
}

module "ecs" {
  source              = "./core/ecs"
  name                = local.var.name
  environment         = local.var.environment
}

#########################################################
# MODULES
#########################################################

module "frontend" {
  source              = "./modules/frontend"
  name                = local.var.name
  environment         = local.var.environment
  region              = local.var.region
  app                 = local.var.apps.frontend
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.vpc_private_subnets
  public_subnets      = module.vpc.vpc_public_subnets
  ecs_cluster_name    = module.ecs.ecs_name
  ecs_cluster_id      = module.ecs.ecs_id
  ecs_log_group       = module.ecs.ecs_log_group
  ecs_task_sg         = [ module.vpc.vpc_sg_ecs ]
  ecs_task_role       = module.iam.ecs_task_execution_role_arn
  main_alb_tg_arn     = module.alb.alb_tg_arn
}
