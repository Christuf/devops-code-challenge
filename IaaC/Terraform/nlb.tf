resource "aws_lb" "network_load_balancer" {
  name               = "nlb-1"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.private : subnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}


resource "aws_lb_listener" "nlb-listener" {
  load_balancer_arn = "${aws_lb.network_load_balancer.arn}" # Referencing our load balancer
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nlb-tg.arn}" # Referencing our tagrte group
  }
  depends_on = [
    aws_lb_target_group.nlb-tg
  ]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [
    aws_vpc.default
  ]
}