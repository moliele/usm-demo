variable "confluent_api_key" {
  type      = string
  sensitive = true
}

variable "confluent_api_secret" {
  type      = string
  sensitive = true
}
variable "region" {
  type = string
}

variable "base_state_path" {
  type    = string
  default = "../terraform.tfstate"
}
