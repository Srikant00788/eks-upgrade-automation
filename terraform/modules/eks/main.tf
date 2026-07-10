resource "aws_eks_cluster" "this" {

  name = "${var.project_name}-${var.environment}"

  version = var.cluster_version

  role_arn = var.cluster_role_arn

  vpc_config {

    subnet_ids = var.private_subnet_ids

    security_group_ids = [
      var.cluster_security_group_id
    ]

    endpoint_private_access = true

    endpoint_public_access = true

    public_access_cidrs = [
      "0.0.0.0/0"
    ]

  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks"
    }
  )
}
resource "aws_eks_node_group" "managed" {

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.environment}-nodes"

  node_role_arn = var.node_role_arn

  subnet_ids = var.private_subnet_ids

  instance_types = var.node_instance_types

  capacity_type = "ON_DEMAND"

  ami_type = "AL2023_x86_64_STANDARD"

  scaling_config {

    desired_size = var.desired_size

    min_size = var.min_size

    max_size = var.max_size

  }

  update_config {

    max_unavailable = 1

  }

  labels = {

    Environment = var.environment

    NodeGroup = "primary"

  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nodegroup"
      "k8s.io/cluster-autoscaler/enabled" = "true"
      "k8s.io/cluster-autoscaler/${var.project_name}-${var.environment}" = "owned"
    }
  )

  depends_on = [
    aws_eks_cluster.this
  ]
}
