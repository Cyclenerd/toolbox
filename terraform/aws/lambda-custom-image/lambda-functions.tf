# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function

resource "aws_lambda_function" "lambda_iot_authorizer" {
  function_name = "iot-mqtt-authorizer"
  description   = "Custom IoT Core authorizer for MQTT using password credentials (Terraform managed)"
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.lambda_iot_authorizer.image_uri
  depends_on    = [data.aws_ecr_image.lambda_iot_authorizer]
  role          = aws_iam_role.lambda_iot_authorizer.arn
  architectures = ["arm64"] # Arm/Graviton processors
  timeout       = 30
  environment {
    variables = {
      PASSWORD_HASH = "$2b$12$rn1rqOuEhbKg5yCvUi.TeeJgs46th7alAD1qwP005LpmXUCDtRmy6"
    }
  }
}

# Invoke permission for AWS IoT custom authorizers
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "lambda_iot_authorizer" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_iot_authorizer.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_authorizer.lambda_iot_authorizer.arn
}