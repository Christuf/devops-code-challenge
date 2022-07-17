data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


data "aws_route_table" "private" {
  subnet_id = "${aws_subnet.private[0].id}"
depends_on = [
  aws_vpc.default,
  aws_route.private
]
}

resource "aws_security_group" "vpc_endpoint_security_group" {
  vpc_id = aws_vpc.default.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.default.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"
  auto_accept = true
  subnet_ids = ["${aws_subnet.private[0].id}", "${aws_subnet.private[1].id}"]
  security_group_ids = [
    aws_security_group.vpc_endpoint_security_group.id
  ]
  tags = {
    Name        = "logs-endpoint"
    Environment = "production"
  }
  private_dns_enabled = true
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.default.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  auto_accept = true
  vpc_endpoint_type = "Gateway"
  route_table_ids   = ["${data.aws_route_table.private.id}"]

  tags = {
    Name        = "s3-endpoint"
    Environment = "production"
  }
  depends_on = [
   aws_vpc.default
  ]
}

resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  auto_accept = true
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint_security_group.id
  ]
  subnet_ids = ["${aws_subnet.private[0].id}", "${aws_subnet.private[1].id}"]


  tags = {
    Name        = "dkr-endpoint"
    Environment = "production"
  }
  depends_on = [
   aws_vpc.default
  ]
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  auto_accept = true
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint_security_group.id
  ]
  subnet_ids = ["${aws_subnet.private[0].id}", "${aws_subnet.private[1].id}"]

  tags = {
    Name        = "ecr-api-endpoint"
    Environment = "production"
  }
  depends_on = [
   aws_vpc.default
  ]
}
