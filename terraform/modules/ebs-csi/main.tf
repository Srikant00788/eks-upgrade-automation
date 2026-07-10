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
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.common_tags
}
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = var.policy_arn
}
resource "aws_eks_addon" "ebs_csi" {

  cluster_name = var.cluster_name

  addon_name = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi
  ]

  tags = var.common_tags

}
