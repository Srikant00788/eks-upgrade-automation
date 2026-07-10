output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}

output "helm_release_name" {
  value = helm_release.aws_load_balancer_controller.name
}
