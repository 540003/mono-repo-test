resource "aws_ecs_cluster" "main" {
  name = "monorepo-cluster"
}

resource "aws_ecs_task_definition" "monorepo_task" {
  family                   = "monorepo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "monorepo-app"
      image     = var.docker_image
      essential = true
      portMappings = [{ containerPort = 3000, hostPort = 3000 }]
    }
  ])
}

resource "aws_ecs_service" "monorepo_service" {
  name            = "monorepo-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.monorepo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.lb_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "monorepo-app"
    container_port   = 3000
  }
}
