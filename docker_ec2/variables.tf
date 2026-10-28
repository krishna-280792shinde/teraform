
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Prefix used for AWS resources"
  type        = string
  default     = "krishna-terraform-ecs"
}

variable "backend_image" {
  description = "ECR image URI for the Flask backend"
  type        = string
}

variable "frontend_image" {
  description = "ECR image URI for the Express frontend"
  type        = string
}
