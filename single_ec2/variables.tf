
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Local path to the matching private PEM file"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Your public IP address in CIDR notation, for example 203.0.113.10/32"
  type        = string
}