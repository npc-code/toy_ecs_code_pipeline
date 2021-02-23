resource "aws_alb" "app_alb" {
  name            = "${var.cluster_name}-alb"
  subnets         = var.subnets
  #security_groups = [aws_security_group.alb_sg.id, aws_security_group.app_sg.id]
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name        = "${var.cluster_name}-alb"
    Environment = var.cluster_name
  }
}

resource "aws_alb_target_group" "api_target_group" {
  name_prefix = substr(var.cluster_name, 0, 6)
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = var.health_check_path
    port = var.container_port
  }

  depends_on = [aws_alb.app_alb]
}

resource "aws_alb_listener" "web_app" {
  #count             = local.can_ssl ? 0 : 1
  load_balancer_arn = aws_alb.app_alb.arn
  port              = var.alb_port
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.api_target_group]

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "web_app_http" {
  #count = local.is_only_http ? 1 : 0

  load_balancer_arn = aws_alb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.api_target_group]

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type             = "forward"
  }
}
