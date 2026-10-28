
output "frontend_url" {
  description = "Public URL for the Express frontend"
  value       = "http://${aws_lb.app.dns_name}"
}

output "backend_url" {
  description = "Public URL for the Flask backend"
  value       = "http://${aws_lb.app.dns_name}:5000"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "frontend_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend.name
}

output "load_balancer_dns" {
  value = aws_lb.app.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}
