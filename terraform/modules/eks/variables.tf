variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM Role ARN for EKS Cluster"
  type        = string
}

variable "cluster_security_group_id" {
  description = "Cluster Security Group ID"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}
variable "node_role_arn" {
  description = "IAM role ARN for worker nodes"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security Group ID for worker nodes"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired node count"
  type        = number
}

variable "min_size" {
  description = "Minimum node count"
  type        = number
}

variable "max_size" {
  description = "Maximum node count"
  type        = number
}
