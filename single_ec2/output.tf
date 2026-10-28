
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "frontend_url" {
  description = "Express frontend URL"
  value       = "http://${aws_instance.app_server.public_ip}:3000"
}

output "backend_url" {
  description = "Flask backend base URL"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}

output "security_group_id" {
  description = "Security group attached to the instance"
  value       = aws_security_group.app_sg.id
}