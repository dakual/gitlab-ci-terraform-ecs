variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "region" {
  description = "region"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "List of subnet IDs"
}

variable "public_subnets" {
  description = "List of subnet IDs"
}

variable "main_alb_tg_arn" {
  description = "main_alb_tg_arn"
}

variable "ecs_log_group" {
  description = "cloudwatch log grooup name"
}

variable "ecs_cluster_id" {
  description = "ecs_cluster_id"
}

variable "ecs_cluster_name" {
  description = "ecs_cluster_name"
}

variable "ecs_task_sg" {
  description = "ecs_task_sg"
}

variable "ecs_task_role" {
  description = "ecs_task_role"
}

variable "app" {
  description = "app vars"
}

variable "efs_id" {
  description = "efs_id"
}

variable "efs_ap_id" {
  description = "efs_ap_id"
}

variable "rds_mysql" {
  description = "rds_mysql"
}