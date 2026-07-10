locals {
  oidc_provider = replace(var.oidc_provider_url, "https://", "")
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
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }
  }
}
resource "aws_iam_role" "alb_controller" {

  name = "${var.cluster_name}-alb-controller-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.common_tags
}
resource "aws_iam_role_policy_attachment" "alb" {

  role = aws_iam_role.alb_controller.name

  policy_arn = var.iam_policy_arn

}
resource "kubernetes_service_account" "alb_controller" {

  metadata {

    name = "aws-load-balancer-controller"

    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.alb
  ]
}
resource "helm_release" "aws_load_balancer_controller" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"

  namespace = "kube-system"

  create_namespace = false

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  depends_on = [
    kubernetes_service_account.alb_controller,
    aws_iam_role_policy_attachment.alb
  ]
}
