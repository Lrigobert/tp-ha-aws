resource "aws_lb" "alb" {
  name               = "tp-ha-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "tp-ha-alb-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
  health_check {
    path     = "/"
    protocol = "HTTPS"
    matcher  = "200-399"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
