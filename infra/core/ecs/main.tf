resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster-${var.environment}"
  tags = {
    Name        = "${var.name}-cluster-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name   = "${var.name}-ecsTaskExecutionRole-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_task" {
  name   = "${var.name}-sg-task-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-sg-task-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "main" {
  for_each  = var.env.apps
  name      = "/ecs/${var.name}-task-${each.key}"

  tags = {
    Name        = "${var.name}-task-${each.key}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "main" {
  for_each                 = var.env.apps
  family                   = "${var.name}-task-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value["task"]["container_cpu"]
  memory                   = each.value["task"]["container_memory"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([{
    name         = "${var.name}-container-${each.key}"
    image        = "nginx:latest"
    essential    = true
    environment  = toset(each.value["task"]["container_environment"])
    portMappings = toset(each.value["task"]["portMappings"])
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main[each.key].name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.env.region
      }
    }
  }])

  tags = {
    Name        = "${var.name}-task-${each.key}"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "main" {
  for_each                           = var.env.apps
  name                               = "${var.name}-service-${each.key}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main[each.key].arn
  desired_count                      = each.value["service"]["deployment_minimum_healthy_percent"]
  deployment_minimum_healthy_percent = each.value["service"]["service_desired_count"]
  deployment_maximum_percent         = each.value["service"]["deployment_maximum_percent"]
  health_check_grace_period_seconds  = each.value["service"]["health_check_grace_period_seconds"]
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [ aws_security_group.ecs_task.id ]
    subnets          = var.subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group_arn
    container_name   = "${var.name}-container-${each.key}"
    container_port   = each.value["loadbalancer"]["container_port"]
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = var.env.apps
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  for_each           = var.env.apps
  name               = "${var.name}-memory-autoscaling-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = each.value["autoscaling"]["memory"]["target_value"]
    scale_in_cooldown  = each.value["autoscaling"]["memory"]["scale_in_cooldown"]
    scale_out_cooldown = each.value["autoscaling"]["memory"]["scale_out_cooldown"]
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  for_each           = var.env.apps
  name               = "${var.name}-cpu-autoscaling-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = each.value["autoscaling"]["cpu"]["target_value"]
    scale_in_cooldown  = each.value["autoscaling"]["cpu"]["scale_in_cooldown"]
    scale_out_cooldown = each.value["autoscaling"]["cpu"]["scale_out_cooldown"]
  }
}


output "ecs_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_name" {
  value = aws_ecs_cluster.main.name
}

