# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository

resource "aws_ecr_repository" "lambda_iot_authorizer" {
  name                 = "lambda-iot-authorizer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "lambda_iot_authorizer" {
  repository = aws_ecr_repository.lambda_iot_authorizer.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 7 days (Terraform managed)",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

data "aws_ecr_image" "lambda_iot_authorizer" {
  repository_name = aws_ecr_repository.lambda_iot_authorizer.name
  image_tag       = "latest"
  depends_on      = [aws_ecr_repository.lambda_iot_authorizer]
}
