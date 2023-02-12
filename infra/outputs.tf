output "rds_host" {
  value = module.rds.rds_host
}

output "rds_dbname" {
  value = module.rds.rds_dbname
}

output "rds_username" {
  value = module.rds.rds_username
}

output "rds_password" {
  value = module.rds.rds_password
  sensitive = true
}