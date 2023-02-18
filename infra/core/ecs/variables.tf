variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnets" {
  description = "List of subnet IDs"
}

variable "env" {
  description = "env vars"
}