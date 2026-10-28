variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private PEM key"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Current public IP allowed to connect over SSH"
  type        = string
}