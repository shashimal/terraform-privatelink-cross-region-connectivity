output "endpoint_service_name" {
  description = "Endpoint service name"
  value       = aws_vpc_endpoint_service.endpoint_service.service_name
}