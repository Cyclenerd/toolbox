output "lambda_iot_authorizer_container_repository_url" {
  description = "ECR repository for custom IoT Core authorizer"
  value       = aws_ecr_repository.lambda_iot_authorizer.repository_url
}