variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "chart_version" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
