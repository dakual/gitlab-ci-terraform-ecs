variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "domain" {
  type    = string
}

variable "alb_zone_id" {
  type    = string
}

variable "alb_dns_name" {
  type    = string
}
