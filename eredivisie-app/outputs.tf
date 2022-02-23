output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value = aws_s3_bucket.lambda-bucket.id
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.api.function_name
}

output "api_gateway_name" {
  description = "Name of the API Gateway"
  value       = aws_api_gateway_rest_api.api_gateway.name
}

output "api_gateway_endpoint" {
  description = "Endpoint that can be used to send GET requests"
  value = join("", ["${aws_api_gateway_deployment.api_deployment.invoke_url}",
                    "${aws_api_gateway_stage.api_gateway_stage.stage_name}"]
               )
}

output "api_key_value" {
  description = "The value of the API key"
  value       = nonsensitive(aws_api_gateway_api_key.api_key.value)
}
