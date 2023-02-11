resource "aws_efs_file_system" "main" {
  creation_token = "${var.name}-efs-${var.environment}"

  tags = {
    Name         = "${var.name}-task-${var.environment}"
    Environment  = var.environment
  }
}

resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = 1001
    uid = 1001
  }
  
  root_directory {
    path = "/bitnami/wordpress"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = 0777
    }
  }
}

resource "aws_efs_mount_target" "main" {
  count = length(var.private_subnets)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnets[count.index].id
  security_groups = [ aws_security_group.efs.id ]
}

resource "aws_security_group" "efs" {
  name        = "${var.name}-sg-efs-${var.environment}"
  description = "Allow EFS inbound traffic from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description      = "NFS traffic from VPC"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # security_groups  = [aws_security_group.tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "id" {
  value = aws_efs_file_system.main.id
}

output "ap_id" {
  value = aws_efs_access_point.main.id
}
