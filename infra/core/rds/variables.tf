variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "rds_security_groups" {
  description = "Comma separated list of security groups"
}

variable "rds_subnets" {
  description = "rds subnets"
}