variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "rds_security_groups" {
  description = "Comma separated list of security groups"
}

variable "db_name" {
  description = "the name of your db"
}

variable "db_username" {
  description = "the username of your db"
}

variable "db_password" {
  description = "the password of your db"
}

variable "rds_subnets" {
  description = "rds subnets"
}