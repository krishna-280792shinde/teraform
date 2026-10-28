
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

# Find the latest Ubuntu 24.04 LTS AMI published by Canonical.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "terraform-single-ec2-app-sg"
  description = "Access for Flask, Express and restricted SSH"

  ingress {
    description = "SSH from the configured public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Express frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound connections"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-single-ec2-app-sg"
    Assignment  = "Terraform"
    Environment = "Learning"
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python3 python3-venv python3-pip nodejs npm
    touch /var/log/terraform-bootstrap-complete
  EOF

  user_data_replace_on_change = true

  tags = {
    Name        = "terraform-flask-express-single-ec2"
    Assignment  = "Terraform"
    Environment = "Learning"
  }

  # Wait for the instance to accept SSH before uploading the apps.
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/backend /home/ubuntu/frontend",
      "while [ ! -f /var/log/terraform-bootstrap-complete ]; do sleep 5; done"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
      timeout     = "15m"
    }
  }

  provisioner "file" {
    source      = "${path.module}/backend/"
    destination = "/home/ubuntu/backend/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
      timeout     = "15m"
    }
  }

  provisioner "file" {
    source      = "${path.module}/frontend/"
    destination = "/home/ubuntu/frontend/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
      timeout     = "15m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/backend /home/ubuntu/frontend",
      "python3 -m venv /home/ubuntu/backend/venv",
      "/home/ubuntu/backend/venv/bin/pip install --upgrade pip",
      "if [ -f /home/ubuntu/backend/requirements.txt ]; then /home/ubuntu/backend/venv/bin/pip install -r /home/ubuntu/backend/requirements.txt; fi",
      "cd /home/ubuntu/frontend && npm install",
      "sudo tee /etc/systemd/system/flask-app.service > /dev/null <<'SERVICE'\n[Unit]\nDescription=Flask Backend\nAfter=network.target\n\n[Service]\nUser=ubuntu\nWorkingDirectory=/home/ubuntu/backend\nEnvironment=PYTHONUNBUFFERED=1\nExecStart=/home/ubuntu/backend/venv/bin/python /home/ubuntu/backend/app.py\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\nSERVICE",
      "sudo tee /etc/systemd/system/express-app.service > /dev/null <<'SERVICE'\n[Unit]\nDescription=Express Frontend\nAfter=network.target\n\n[Service]\nUser=ubuntu\nWorkingDirectory=/home/ubuntu/frontend\nExecStart=/usr/bin/node /home/ubuntu/frontend/server.js\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\nSERVICE",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable flask-app express-app",
      "sudo systemctl restart flask-app express-app"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
      timeout     = "15m"
    }
  }
}
