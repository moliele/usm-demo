output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.privatelink.id
}

output "vpc_endpoint_dns_name" {
  value = aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"]
}
