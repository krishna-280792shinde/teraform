output "vpc_id" {
  description = "ID of the custom VPC"
  value       = aws_vpc.app_vpc.id
}

output "backend_instance_id" {
  description = "EC2 instance ID for Flask"
  value       = aws_instance.backend.id
}

output "backend_public_ip" {
  description = "Public IP of Flask backend"
  value       = aws_instance.backend.public_ip
}

output "backend_url" {
  description = "Flask backend URL"
  value       = "http://${aws_instance.backend.public_ip}:5000"
}

output "frontend_instance_id" {
  description = "EC2 instance ID for Express"
  value       = aws_instance.frontend.id
}

output "frontend_public_ip" {
  description = "Public IP of Express frontend"
  value       = aws_instance.frontend.public_ip
}

output "frontend_url" {
  description = "Express frontend URL"
  value       = "http://${aws_instance.frontend.public_ip}:3000"
}