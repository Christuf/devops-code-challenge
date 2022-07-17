variable "backend_service_container_port" {
  default = 8080
}

variable "backend_service_container_name" {
  default = "backend-service"
}

//"image": "${aws_ecr_repository.backend-service-ecr.repository_url}",
resource "aws_ecs_task_definition" "backend-service-task-defintion" {
  family                   = "backend-service" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.backend_service_container_name}",
      "image": "${aws_ecr_repository.backend-service-ecr.repository_url}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/service-cluster/backend-service",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
          "retries": 3,
          "command": [
              "CMD-SHELL",
              "curl -f http://localhost:${var.backend_service_container_port}/ || exit 1"
          ],
          "timeout": 10,
          "interval": 30,
          "startPeriod": 30
      },
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": ${var.backend_service_container_port}
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  depends_on = [
    aws_ecr_repository.backend-service-ecr,
    aws_cloudwatch_log_group.backend-service_cw_log_group
  ]
  lifecycle {
    ignore_changes = [container_definitions]
  }
}


resource "aws_cloudwatch_log_group" "backend-service_cw_log_group" {
  name = "/ecs/service-cluster/backend-service"
  tags = {
    Environment = "production"
    Application = "backend-service"
  }
}

resource "aws_lb_target_group" "nlb-tg" {
  name        = "bk-nlb-tg"
  protocol    = "TCP"
  target_type = "ip"
  deregistration_delay = 5
  connection_termination = true
  vpc_id      = aws_vpc.default.id
  port = var.backend_service_container_port
  health_check {
    protocol = "TCP"
    interval = 10
  }
}


resource "aws_security_group" "backend-service_security_group" {
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "backend-service" {
  name            = "backend-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.service-cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.backend-service-task-defintion.arn}" # Referencing the task our service will spin up

# Break the deployment if new tasks are not able to run and revert back to previous state

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
    base = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  desired_count   = 1 # Setting the number of containers to 1
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = "${aws_lb_target_group.nlb-tg.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.backend-service-task-defintion.family}"
    container_port   = "${var.backend_service_container_port}" # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_subnet.private[0].id}", "${aws_subnet.private[1].id}"]
    assign_public_ip = false # Providing our containers with private IPs
    security_groups  = ["${aws_security_group.backend-service_security_group.id}"] # Setting the security group
  }

  depends_on = [
    aws_ecs_cluster.service-cluster,
    aws_lb.network_load_balancer
  ]

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

resource "aws_appautoscaling_target" "backend-service_ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.service-cluster.name}/${aws_ecs_service.backend-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.ecs-autoscale-role.arn
}


resource "aws_appautoscaling_policy" "ecs_target_cpu-service-backend" {
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend-service_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend-service_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend-service_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
  depends_on = [aws_appautoscaling_target.backend-service_ecs_target]
}
resource "aws_appautoscaling_policy" "ecs_target_memory-service-backend" {
  name               = "application-scaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend-service_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend-service_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend-service_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
  depends_on = [aws_appautoscaling_target.backend-service_ecs_target]
}
