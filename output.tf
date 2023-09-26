output "api_gateway_url" {
  description = "URL of the API Gateway with '/resource'"
  value       = format("%s%s", aws_api_gateway_deployment.deployment.invoke_url, "/resource")
}