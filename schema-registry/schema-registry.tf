terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.76.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_api_key
  cloud_api_secret = var.confluent_api_secret
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "base" {
  backend = "local"

  config = {
    path = var.base_state_path
  }
}

data "confluent_schema_registry_cluster" "remote" {
  environment {
    id = data.terraform_remote_state.base.outputs.environment_id
  }
}

locals {
  schema_registry_cluster_id  = data.confluent_schema_registry_cluster.remote.id
  schema_registry_private_url = "https://${local.schema_registry_cluster_id}.${var.region}.aws.private.confluent.cloud"
}

resource "aws_route53_zone" "schema_registry_private" {
  name = "${var.region}.aws.private.confluent.cloud"

  vpc {
    vpc_id = data.terraform_remote_state.base.outputs.vpc-id
  }
}

resource "aws_route53_record" "schema_registry" {
  zone_id = aws_route53_zone.schema_registry_private.zone_id
  name    = local.schema_registry_cluster_id
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.base.outputs.vpc_endpoint_dns_name]
}

output "schema_registry_cluster_id" {
  value = local.schema_registry_cluster_id
}

output "cfk_remote_schema_registry_endpoint" {
  value = local.schema_registry_private_url
}
