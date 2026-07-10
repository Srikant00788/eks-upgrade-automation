variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet definitions"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnet definitions"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
