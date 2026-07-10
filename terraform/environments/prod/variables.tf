variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
}
