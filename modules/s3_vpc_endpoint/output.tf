output "endpoint" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = data.aws_vpc_endpoint.this
}