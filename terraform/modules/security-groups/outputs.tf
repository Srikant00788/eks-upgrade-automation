output "cluster_security_group_id" {

  value = aws_security_group.cluster.id

}

output "worker_security_group_id" {

  value = aws_security_group.worker.id

}
