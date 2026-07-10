output "cluster_role_arn" {

  value = aws_iam_role.cluster_role.arn

}

output "node_role_arn" {

  value = aws_iam_role.node_role.arn

}

output "instance_profile_name" {

  value = aws_iam_instance_profile.node.name

}
