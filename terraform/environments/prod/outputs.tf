output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "oidc_provider_arn" {
  value = module.irsa.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.irsa.oidc_provider_url
}
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_repository_name" {
  value = module.ecr.repository_name
}
