locals {
  security_group_ids = [
    aws_security_group.ecs_sg.id
  ]
}

resource "aws_ecs_service" "web-api" {
  name            = var.cluster_name
  task_definition = aws_ecs_task_definition.web-api.arn
  cluster         = aws_ecs_cluster.cluster.id
  launch_type     = "FARGATE"
  desired_count   = var.desired_tasks
  health_check_grace_period_seconds = 600

  //  deployment_controller {
  //    type = "CODE_DEPLOY"
  //  }

  #should tweak this so we only use the correct security group, and make sure that our stuff goes to a private subnet
  network_configuration {
    security_groups  = local.security_group_ids
    subnets = var.container_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      # task_definition,
      load_balancer,
    ]
  }

  depends_on = [aws_iam_role_policy.ecs_service_role_policy, aws_alb_target_group.api_target_group]
}

