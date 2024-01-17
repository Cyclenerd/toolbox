# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

resource "aws_cloudwatch_log_group" "lambda_iot_authorizer" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_iot_authorizer.function_name}"
  retention_in_days = 7
}