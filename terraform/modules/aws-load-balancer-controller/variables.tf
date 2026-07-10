variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
variable "iam_policy_arn" {
  type = string
}
variable "chart_version" {
  type        = string
  description = "AWS Load Balancer Controller Helm chart version"
}
