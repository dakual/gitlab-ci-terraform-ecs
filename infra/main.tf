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
      tags = [
        "ecs"
      ]
    }
  }

  required_version = ">= 1.3.6"
}

provider "aws" {
  region  = local.var.region
}

locals {
    workspace_path = "${path.module}/workspaces/${terraform.workspace}.yaml" 
    defaults       = file("${path.module}/workspaces/config.yaml")

    workspace = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})
    var       = merge(
        yamldecode(local.defaults),
        yamldecode(local.workspace)
    )
}

output "workspace_variables" {
    value = local.var
}

module "iam" {
  source              = "./modules/iam"
  name                = local.var.name
  environment         = local.var.environment
}

module "rds" {
  source              = "./modules/rds"
  name                = local.var.name
  environment         = local.var.environment
  db_name             = local.var.db_name
  db_username         = local.var.db_username
  db_password         = local.var.db_password
  rds_security_groups = [ module.vpc.rds ]
  rds_subnets         = module.vpc.private_subnets
}

module "vpc" {
  source              = "./modules/vpc"
  name                = local.var.name
  cidr                = local.var.cidr
  private_subnets     = local.var.private_subnets
  public_subnets      = local.var.public_subnets
  availability_zones  = local.var.availability_zones
  container_port      = local.var.container_port
  environment         = local.var.environment
}

module "efs" {
  source              = "./modules/efs"
  name                = local.var.name
  private_subnets     = module.vpc.private_subnets
  vpc_id              = module.vpc.id
  environment         = local.var.environment
}

module "alb" {
  source              = "./modules/alb"
  name                = local.var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = local.var.environment
  alb_security_groups = [ module.vpc.alb ]
  alb_tls_cert_arn    = local.var.tsl_certificate_arn
  health_check_path   = local.var.health_check_path
}

module "ecr" {
  source              = "./modules/ecr"
  name                = local.var.name
  environment         = local.var.environment
}

module "ecs" {
  source                      = "./modules/ecs"
  name                        = local.var.name
  environment                 = local.var.environment
  region                      = local.var.region
  subnets                     = module.vpc.private_subnets
  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  ecs_service_security_groups = [ module.vpc.ecs_tasks ]
  efs_id                      = module.efs.id
  efs_ap_id                   = module.efs.ap_id
  container_image             = local.var.container_image
  container_port              = local.var.container_port
  container_cpu               = local.var.container_cpu
  container_memory            = local.var.container_memory
  service_desired_count       = local.var.service_desired_count
  container_environment       = [{
        name  = "DATABASE_HOST"
        value = module.rds.db
    },{
        name  = "DATABASE_NAME"
        value = local.var.db_name
    },{
        name  = "DATABASE_USER"
        value = local.var.db_username
    },{
        name  = "DATABASE_PASSWORD"
        value = local.var.db_password
    },{
        name  = "ALLOW_EMPTY_PASSWORD"
        value = "true"
  }]
}