# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.cluster_name}-app-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = var.cluster_name
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.cluster_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.alb_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }

  ingress {
    from_port   = "80"
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }

  #ingress {
  #  from_port   = "443"
  #  to_port     = "443" #"${var.container_port}"
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  #ingress {
  #  from_port   = 8
  #  to_port     = 0
  #  protocol    = "icmp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #egress {
  #  from_port   = 0
  #  to_port     = 0
  #  protocol    = "-1"
  #  security_groups = [aws_security_group.ecs_sg.id]
    #cidr_blocks = ["0.0.0.0/0"]
    
  #}

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

# ECS Cluster Security Group
resource "aws_security_group" "ecs_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.cluster_name}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
      from_port = 5000
      to_port = 5000
      protocol = "tcp"
      security_groups = [aws_security_group.alb_sg.id]
      
  }

  tags = {
    Name        = "${var.cluster_name}-ecs-service-sg"
    Environment = var.cluster_name
  }
}

resource "aws_security_group_rule" "alb_to_ecs" {
  security_group_id        = aws_security_group.alb_sg.id
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  type                     = "egress"
  source_security_group_id = aws_security_group.ecs_sg.id
}

#resource "aws_security_group_rule" "ecs_to_alb" {
#  security_group_id        = "${aws_security_group.ecs_sg.id}"
#  from_port                = var.container_port
#  to_port                  = var.container_port
#  protocol                 = "tcp"
#  type                     = "ingress"
#  source_security_group_id = "${aws_security_group.alb_sg.id}"
#}

