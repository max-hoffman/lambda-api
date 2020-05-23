output "prod_api" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}
