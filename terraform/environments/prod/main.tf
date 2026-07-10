module "vpc" {

  source = "../../modules/vpc"

  project_name = var.project_name

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnets = {
    public-1 = {
      cidr = "10.0.1.0/24"
      az   = data.aws_availability_zones.available.names[0]
    }

    public-2 = {
      cidr = "10.0.2.0/24"
      az   = data.aws_availability_zones.available.names[1]
    }
  }

  private_subnets = {
    private-1 = {
      cidr = "10.0.11.0/24"
      az   = data.aws_availability_zones.available.names[0]
    }

    private-2 = {
      cidr = "10.0.12.0/24"
      az   = data.aws_availability_zones.available.names[1]
    }
  }

  common_tags = local.common_tags

}
module "iam" {

  source = "../../modules/iam"

  project_name = var.project_name

  environment = var.environment

  common_tags = local.common_tags

}
module "security_groups" {

  source = "../../modules/security-groups"

  project_name = var.project_name

  environment = var.environment

  vpc_id = module.vpc.vpc_id

  common_tags = local.common_tags

}
module "eks" {

  source = "../../modules/eks"

  project_name = var.project_name

  environment = var.environment

  cluster_version = var.cluster_version

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = values(module.vpc.private_subnets)

  cluster_role_arn = module.iam.cluster_role_arn

  cluster_security_group_id = module.security_groups.cluster_security_group_id

  common_tags = local.common_tags

  node_role_arn = module.iam.node_role_arn

  worker_security_group_id = module.security_groups.worker_security_group_id

  node_instance_types = [
    "m7i-flex.large"
  ]

  desired_size = 3

  min_size = 3

  max_size = 5
}
module "irsa" {

  source = "../../modules/irsa"

  cluster_name = module.eks.cluster_name

  oidc_issuer_url = module.eks.oidc_issuer_url

  common_tags = local.common_tags
}
module "ebs_csi" {
  source = "../../modules/ebs-csi"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.irsa.oidc_provider_arn
  oidc_provider_url = module.irsa.oidc_provider_url

  policy_arn = "arn:aws:iam::904464083565:policy/AmazonEBSCSIDriverPolicy"

  common_tags = local.common_tags
}
module "aws_load_balancer_controller" {

  source = "../../modules/aws-load-balancer-controller"

  cluster_name = module.eks.cluster_name

  region = var.aws_region

  vpc_id = module.vpc.vpc_id

  oidc_provider_arn = module.irsa.oidc_provider_arn

  oidc_provider_url = module.irsa.oidc_provider_url

  chart_version = "3.4.1"

  iam_policy_arn = "arn:aws:iam::904464083565:policy/AWSLoadBalancerControllerIAMPolicy"

  common_tags = local.common_tags

  depends_on = [
    module.eks,
    module.irsa
  ]
}
module "metrics_server" {

  source = "../../modules/metrics-server"

  chart_version = "3.13.0"

  common_tags = local.common_tags

  depends_on = [
    module.eks
  ]
}
module "cluster_autoscaler" {

  source = "../../modules/cluster-autoscaler"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint

  oidc_provider_arn = module.irsa.oidc_provider_arn
  oidc_provider_url = module.irsa.oidc_provider_url

  aws_region = var.aws_region

  chart_version = "9.46.6"

  common_tags = local.common_tags

  depends_on = [
    module.eks,
    module.metrics_server,
    module.irsa
  ]
}
module "ecr" {

  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  common_tags = local.common_tags
}
module "argocd" {

  source = "../../modules/argocd"

  cluster_name = "${var.project_name}-${var.environment}"

  common_tags = local.common_tags

  depends_on = [
    module.aws_load_balancer_controller
  ]
}
