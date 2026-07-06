provider "confluent" {
  cloud_api_key    = var.confluent_api_key
  cloud_api_secret = var.confluent_api_secret
}

resource "confluent_environment" "usm_environment" {
  display_name = "USM-${var.username}"

  stream_governance {
    package = "ADVANCED"
  }
}

resource "confluent_gateway" "usm_gateway" {
  display_name = "usm-ingress-gateway"

  environment {
    id = confluent_environment.usm_environment.id
  }

  aws_ingress_private_link_gateway {
    region = var.region
  }
}

module "privatelink" {
  source = "./aws-ingress-access-point"

  vpc_id                   = aws_vpc.vpc.id
  privatelink_service_name = one(confluent_gateway.usm_gateway.aws_ingress_private_link_gateway).vpc_endpoint_service_name
  subnets_to_privatelink   = local.subnets_to_privatelink
}

resource "confluent_access_point" "usm_access_point" {
  display_name = "usm-ingress-ap"

  environment {
    id = confluent_environment.usm_environment.id
  }

  gateway {
    id = confluent_gateway.usm_gateway.id
  }

  aws_ingress_private_link_endpoint {
    vpc_endpoint_id = module.privatelink.vpc_endpoint_id
  }

  depends_on = [confluent_gateway.usm_gateway]
}

locals {
  usm_access_point_dns_domain    = one(confluent_access_point.usm_access_point.aws_ingress_private_link_endpoint).dns_domain
  usm_frontdoor_host             = "api-${replace(local.usm_access_point_dns_domain, ".accesspoint.", ".accesspoint.glb.")}"
}

resource "aws_route53_zone" "usm_privatelink" {
  name = local.usm_access_point_dns_domain

  vpc {
    vpc_id = aws_vpc.vpc.id
  }

  depends_on = [confluent_access_point.usm_access_point]
}

resource "aws_route53_record" "usm_privatelink_wildcard" {
  zone_id = aws_route53_zone.usm_privatelink.zone_id
  name    = "*.${local.usm_access_point_dns_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [module.privatelink.vpc_endpoint_dns_name]

  depends_on = [confluent_access_point.usm_access_point]
}

output "usm_frontdoor_url" {
  value = "https://${local.usm_frontdoor_host}:443"
}

output "usm_access_point_dns_domain" {
  value = local.usm_access_point_dns_domain
}
