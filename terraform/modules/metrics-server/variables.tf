variable "chart_version" {
  description = "Metrics Server Helm chart version"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}
