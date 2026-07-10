locals {
  oidc_provider = replace(var.oidc_provider_url, "https://", "")
}

data "aws_iam_policy_document" "cluster_autoscaler" {

  statement {

    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = ["*"]

    condition {

      test = "StringEquals"

      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled"

      values = ["true"]
    }

    condition {

      test = "StringEquals"

      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"

      values = ["owned"]
    }

  }

  statement {

    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchTemplateVersions",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }
}
resource "aws_iam_policy" "cluster_autoscaler" {

  name = "${var.cluster_name}-cluster-autoscaler"

  policy = data.aws_iam_policy_document.cluster_autoscaler.json

  tags = var.common_tags
}
data "aws_iam_policy_document" "assume_role" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {

      type = "Federated"

      identifiers = [
        var.oidc_provider_arn
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${local.oidc_provider}:sub"

      values = [
        "system:serviceaccount:kube-system:cluster-autoscaler"
      ]
    }
  }
}
resource "aws_iam_role" "cluster_autoscaler" {

  name = "${var.cluster_name}-cluster-autoscaler-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {

  role = aws_iam_role.cluster_autoscaler.name

  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}
resource "kubernetes_service_account" "cluster_autoscaler" {

  metadata {

    name      = "cluster-autoscaler"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }

    labels = {
      "app.kubernetes.io/name" = "cluster-autoscaler"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_autoscaler
  ]
}
resource "helm_release" "cluster_autoscaler" {

  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false

  version = var.chart_version

  wait    = true
  timeout = 300
    set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }

  set {
    name  = "extraArgs.expander"
    value = "least-waste"
  }
    depends_on = [
    kubernetes_service_account.cluster_autoscaler
  ]
}
