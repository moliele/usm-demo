output "private-key-name" {
  description = "The private key name needed to log into the jumphost"
  value = local_file.private_key.filename
}

output "jumphost-ip" {
  description = "The jumphost IP. Remember that the username is 'ubuntu'"
  value = aws_instance.jumphost.public_ip
}

output "vpc-id" {
  description = "The IP of the bootcamp VPC"
  value = aws_vpc.vpc.id
}

output "internal-vpc-security-group-id" {
  description = "Id of the security group for internal access"
  value = aws_security_group.all-usm.id
}

output "external-vpc-security-group-id" {
  description = "Id of the security group for external access"
  value = aws_security_group.external-access.id
}

output "public-subnet-ids" {
  description = "Public subnet for all external-facing instances"
  value = aws_subnet.usm-public-subnet.*.id
}

output "private-subnet-ids" {
  description = "Subnet AZ1 for creating Confluent Cluster"
  value = aws_subnet.usm-private-subnet.*.id
}

output "availability-zones" {
  description = "Availability zones corresponding to the subnet ids"
  value = aws_subnet.usm-private-subnet.*.availability_zone
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "environment_id" {
  value = confluent_environment.usm_environment.id
}

output "region" {
  value = var.region
}

output "route53_zone_id" {
  value = aws_route53_zone.usm_privatelink.zone_id
}

output "vpc_endpoint_dns_name" {
  value = module.privatelink.vpc_endpoint_dns_name
}
