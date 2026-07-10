#############################################
# EKS Cluster Role
#############################################

resource "aws_iam_role" "cluster_role" {

  name = "${var.project_name}-${var.environment}-cluster-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "eks.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = var.common_tags

}

#############################################
# Cluster Policy
#############################################

resource "aws_iam_role_policy_attachment" "cluster_policy" {

  role = aws_iam_role.cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

#############################################
# Worker Node Role
#############################################

resource "aws_iam_role" "node_role" {

  name = "${var.project_name}-${var.environment}-node-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = var.common_tags

}
#############################################
# Worker Policies
#############################################

resource "aws_iam_role_policy_attachment" "worker" {

  role = aws_iam_role.node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

resource "aws_iam_role_policy_attachment" "cni" {

  role = aws_iam_role.node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

resource "aws_iam_role_policy_attachment" "ecr" {

  role = aws_iam_role.node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_iam_instance_profile" "node" {

  name = "${var.project_name}-${var.environment}-node-profile"

  role = aws_iam_role.node_role.name

}
