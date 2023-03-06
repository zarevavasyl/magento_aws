resource "aws_lb_target_group" "tg-http-varnish-for-alb" {
  name     = "tg-http-varnish-for-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.magento-vpc.id
  
  health_check {
    path                = "/varnish-status"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }


  tags = {
        Name: "${var.env_prefix}-tg-http-varnish-for-alb"
  }

}

resource "aws_lb_target_group" "tg-http-magento-for-alb" {
  name     = "tg-http-magento-for-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.magento-vpc.id

  health_check {
    path                = "/health_check.php"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
        Name: "${var.env_prefix}-tg-http-magento-for-alb"
  }

}

resource "aws_lb_target_group" "alb-80" {
  name        = "tf-80-lb-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.magento-vpc.id

  health_check {
    path                = "/health_check.php"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
        Name: "${var.env_prefix}-alb-80"
  }

}

resource "aws_lb_target_group" "alb-443" {
  name        = "tf-443-lb-alb-tg"
  target_type = "alb"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.magento-vpc.id

health_check {
    path                = "/health_check.php"
    port                = 443
    protocol            = "HTTPS"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
        Name: "${var.env_prefix}-alb-443"
  }

}

resource "aws_lb_target_group_attachment" "tga-tg-http-magento-for-alb" {
  target_group_arn = aws_lb_target_group.tg-http-magento-for-alb.arn
  target_id        = aws_instance.magento-server.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tga-tg-http-varnish-for-alb" {
  target_group_arn = aws_lb_target_group.tg-http-varnish-for-alb.arn
  target_id        = aws_instance.varnish-magento-server.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tga-tf-443-lb-alb-tg-for-nlb" {
  depends_on       = [
    aws_lb_listener.forward-to-alb-443
  ]

  target_group_arn = aws_lb_target_group.alb-443.arn
  target_id        = aws_lb.magentoapp-lb.id
}

resource "aws_lb_target_group_attachment" "tga-tf-80-lb-alb-tg-for-nlb" {
  depends_on       = [
    aws_lb_listener.forward-to-alb-80
  ]

  target_group_arn = aws_lb_target_group.alb-80.arn
  target_id        = aws_lb.magentoapp-lb.id
}


