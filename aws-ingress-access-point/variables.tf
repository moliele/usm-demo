variable "vpc_id" {
  description = "The VPC ID to private link to Confluent Cloud"
  type        = string
}

variable "privatelink_service_name" {
  description = "The service name for the AWS VPC endpoint"
  type        = string
}

variable "subnets_to_privatelink" {
  description = "A map of subnet objects"
  type = map(object({
    id    = string
    az    = string
    az_id = string
  }))
}
