resource "aws_db_instance" "main" {
  identifier           = "${var.name}-db-${var.environment}"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = aws_db_parameter_group.main.name
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.rds_security_groups 
  publicly_accessible  = false
  skip_final_snapshot  = true
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.name}-rds-pg-${var.environment}"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-rds-subnet-${var.environment}"
  subnet_ids = var.rds_subnets.*.id

  tags = {
    Name        = "${var.name}-db-subnet-${var.environment}"
    Environment = var.environment
  }
}

output "db" {
  value = aws_db_instance.main.address
}
