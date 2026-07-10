output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi.arn
}
output "ebs_csi_addon_version" {
  value = aws_eks_addon.ebs_csi.addon_version
}
