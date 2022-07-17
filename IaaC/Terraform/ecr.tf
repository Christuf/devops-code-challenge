resource "aws_ecr_repository" "backend-service-ecr" {
  name = "backend-service-ecr"
  lifecycle {
    prevent_destroy = true
  }
}

