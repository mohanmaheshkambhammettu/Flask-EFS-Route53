output "vpc_id" {
  value = aws_vpc.main.id
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  value = aws_lb.api_alb.dns_name
}