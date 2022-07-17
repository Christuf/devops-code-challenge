output "aws_vpc_id" {
    value = aws_vpc.default.id
}

output "ecsTaskExecutionRole_arn" {
    value = aws_iam_role.ecsTaskExecutionRole.arn
}


output "cluster_name" {
    value = aws_ecs_cluster.service-cluster.name
}

//The API Gateway endpoint
output "api_gateway_endpoint" {
  value = "${aws_api_gateway_deployment.main.invoke_url}"
}

