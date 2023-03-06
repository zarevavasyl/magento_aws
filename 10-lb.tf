resource "aws_lb" "magentoapp-lb" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.for_lb.id]
  subnets = [aws_subnet.magento-subnet-1.id, aws_subnet.magento-subnet-2.id]
  enable_deletion_protection = false


  tags = {
        Name: "${var.env_prefix}-magentoapp-lb"
  }
}

resource "aws_lb" "magentoapp-network-lb" {
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.magento-subnet-1.id
    allocation_id = aws_eip.magentoapp-network-lb-ip.id
  }

  tags = {
        Name: "${var.env_prefix}-magentoapp-network-lb"
  }
}

resource "aws_lb_listener" "front_end_443" {
  load_balancer_arn = aws_lb.magentoapp-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_iam_server_certificate.domain_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-http-varnish-for-alb.arn
  }

  tags = {
        Name: "${var.env_prefix}-lis-front_end_443"
  }
}

resource "aws_lb_listener_rule" "static-media" {
  listener_arn = aws_lb_listener.front_end_443.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-http-magento-for-alb.arn
  }

  condition {
    path_pattern {
      values = ["/static/*","/media/*"]
    }
  }

  tags = {
        Name: "${var.env_prefix}-lis-rule-static-media"
  }
}

resource "aws_lb_listener" "redirect-80-443" {
  load_balancer_arn = aws_lb.magentoapp-lb.arn
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

  tags = {
        Name: "${var.env_prefix}-lis-redirect-80-443"
  }
}

resource "aws_lb_listener" "forward-to-alb-80" {
  load_balancer_arn = aws_lb.magentoapp-network-lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-80.arn
  }

  tags = {
        Name: "${var.env_prefix}-lis-forward-to-alb-80"
  }
}

resource "aws_lb_listener" "forward-to-alb-443" {
  load_balancer_arn = aws_lb.magentoapp-network-lb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-443.arn
  }

  tags = {
        Name: "${var.env_prefix}-lis-forward-to-alb-443"
  }
}