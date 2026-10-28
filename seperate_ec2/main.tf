terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------
# VPC and networking
# -------------------------

resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "terraform-part2-vpc"
    Assignment  = "Terraform-Part2"
    Environment = "Dev"
  }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "terraform-part2-igw"
  }
}

resource "aws_subnet" "backend_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-backend-public-subnet"
  }
}

resource "aws_subnet" "frontend_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-frontend-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name = "terraform-part2-public-route-table"
  }
}

resource "aws_route_table_association" "backend_route" {
  subnet_id      = aws_subnet.backend_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "frontend_route" {
  subnet_id      = aws_subnet.frontend_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# Security groups
# -------------------------

resource "aws_security_group" "backend_sg" {
  name        = "terraform-part2-backend-sg"
  description = "Access for Flask backend and SSH"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "SSH from current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Flask backend test access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-part2-backend-sg"
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "terraform-part2-frontend-sg"
  description = "Access for Express frontend and SSH"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "SSH from current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Express frontend HTTP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-part2-frontend-sg"
  }
}

# -------------------------
# EC2 instances
# -------------------------

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.backend_subnet.id
  vpc_security_group_ids      = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip
    touch /var/log/terraform-bootstrap-complete
  EOF

  tags = {
    Name        = "terraform-part2-flask-backend"
    Assignment  = "Terraform-Part2"
    Environment = "Dev"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/log/terraform-bootstrap-complete ]; do sleep 5; done",
      "mkdir -p /home/ubuntu/backend"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/backend/"
    destination = "/home/ubuntu/backend/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/backend",
      "python3 -m venv /home/ubuntu/backend/venv",
      "/home/ubuntu/backend/venv/bin/pip install --upgrade pip",
      "/home/ubuntu/backend/venv/bin/pip install -r /home/ubuntu/backend/requirements.txt",
      "sudo tee /etc/systemd/system/flask-app.service > /dev/null <<'SERVICE'\n[Unit]\nDescription=Flask Backend Application\nAfter=network.target\n\n[Service]\nUser=ubuntu\nWorkingDirectory=/home/ubuntu/backend\nExecStart=/home/ubuntu/backend/venv/bin/python /home/ubuntu/backend/app.py\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\nSERVICE",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable flask-app",
      "sudo systemctl restart flask-app"
    ]
  }
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.frontend_subnet.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm
    touch /var/log/terraform-bootstrap-complete
  EOF

  tags = {
    Name        = "terraform-part2-express-frontend"
    Assignment  = "Terraform-Part2"
    Environment = "Dev"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/log/terraform-bootstrap-complete ]; do sleep 5; done",
      "mkdir -p /home/ubuntu/frontend"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/frontend/"
    destination = "/home/ubuntu/frontend/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/frontend",
      "cd /home/ubuntu/frontend && npm install",
      "sudo tee /etc/systemd/system/express-app.service > /dev/null <<'SERVICE'\n[Unit]\nDescription=Express Frontend Application\nAfter=network.target\n\n[Service]\nUser=ubuntu\nWorkingDirectory=/home/ubuntu/frontend\nExecStart=/usr/bin/node /home/ubuntu/frontend/server.js\nRestart=always\nEnvironment=PORT=3000\nEnvironment=BACKEND_URL=http://${aws_instance.backend.public_ip}:5000\n\n[Install]\nWantedBy=multi-user.target\nSERVICE",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable express-app",
      "sudo systemctl restart express-app"
    ]
  }
}
