resource "aws_alb" "app_alb" {
  name            = "${var.cluster_name}-alb"
  subnets         = var.subnets
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name        = "${var.cluster_name}-alb"
    Environment = var.cluster_name
  }
}

#TODO
resource "aws_route53_record" "alb_endpoint" {
  count = var.use_cert ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_alb.app_alb.dns_name
    zone_id                = aws_alb.app_alb.zone_id
    evaluate_target_health = true
  }
}

#going to add in all the route53 stuff here, including ACM stuff.
resource "aws_acm_certificate" "cert_request" {
  domain_name               = var.domain_name
  validation_method         = "DNS"

  tags = {
    Name : var.domain_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert_request.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
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
    timeout = 29
  }

  depends_on = [aws_alb.app_alb]
}

resource "aws_alb_listener" "web_app" {
  #count             = local.can_ssl ? 0 : 1
  count = var.use_cert ? 0 : 1
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
  count = var.use_cert ? 0 : 1

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

resource "aws_alb_listener" "http_forward" {
  count = var.use_cert ? 1 : 0
  load_balancer_arn = aws_alb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "web_app_https" {
  count = var.use_cert ? 1 : 0
  load_balancer_arn = aws_alb.app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.cert_request.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"
  depends_on        = [aws_alb_target_group.api_target_group]

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type             = "forward"
  }
}
