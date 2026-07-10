variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "policy_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
