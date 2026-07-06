terraform {
  required_providers {
    curl = {
      version = "1.0.2"
      source  = "anschoewe/curl"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.76.0"
    }
  }
}
