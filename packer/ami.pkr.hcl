packer {
  required_version = ">= 1.14.1"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

variable "region" {
  type    = string
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "tag_name"     { type = string }
variable "environment"  { type = string }
variable "ecr_registry" { type = string }
variable "img_tag"      { type = string }

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name  = "visitor-log-system-${var.tag_name}-${local.timestamp}"
}

source "amazon-ebs" "al2" {
  communicator            = "ssh" 
  region                  = var.region
  instance_type           = var.instance_type
  ami_name                = local.ami_name
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["137112412989"] # Amazon
    most_recent = true
  }
  tags = {
    Project     = "visitor-log-system"
    Owner       = "bilal"
    BuildTime   = "${local.timestamp}"
    GitTag      = "${var.tag_name}"
    Env         = "${var.environment}"
  }
  ssh_username  = "ec2-user"
}

build {
  name    = "docker-compose-app"
  sources = ["source.amazon-ebs.al2"]

  provisioner "shell" {
    inline = [
      "mkdir app",
      "cat <<EOF > /home/ec2-user/app/.env",
      "TAG_NAME=${var.tag_name}",
      "ECR_REG=${var.ecr_registry}",
      "IMG_TAG=${var.img_tag}",
      "PROJECT_NAME=visitor-log-system",
      "ENV=${var.environment}",
      "AWS_REGION=${var.region}",
      "EOF"
    ]
  }

  # Install Docker + Compose
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable docker",
      "sudo yum install -y docker git -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",

      # Install Docker Compose plugin (v2) globally
      "sudo mkdir -p /usr/libexec/docker/cli-plugins",
      "curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o docker-compose",
      "chmod +x docker-compose",
      "sudo mv docker-compose /usr/libexec/docker/cli-plugins/docker-compose"
    ]
  }

  # Copy docker-compose.yml
  provisioner "file" {
    source      = "./../docker-compose.yml"
    destination = "/home/ec2-user/app/docker-compose.yml"
  }

  # Copy systemd unit file
  provisioner "file" {
    source      = "./files/docker-compose-app.service"
    destination = "/tmp/docker-compose-app.service"
  }

  provisioner "file" {
    source      = "./files/update-db-token.service"
    destination = "/tmp/update-db-token.service"
  }

  provisioner "file" {
    source      = "./files/update-db-token.timer"
    destination = "/tmp/update-db-token.timer"
  }

  # Set permissions for ecr login
  provisioner "file" {
    source      = "./files/init.sh"
    destination = "/home/ec2-user/app/init.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/ec2-user/app/init.sh"
    ]
  }

  provisioner "file" {
    source      = "./../nginx.conf"
    destination = "/home/ec2-user/app/nginx.conf"
  }

  # Copy DB token update script
  provisioner "file" {
    source      = "./files/update-db-token.sh"
    destination = "/home/ec2-user/app/update-db-token.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/ec2-user/app/update-db-token.sh"
    ]
  } 

  # Install and enable systemd service
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/docker-compose-app.service /etc/systemd/system/",
      "sudo mv /tmp/update-db-token.service /etc/systemd/system/",
      "sudo mv /tmp/update-db-token.timer /etc/systemd/system/",
      "sudo chown root:root /etc/systemd/system/docker-compose-app.service",
      "sudo chown root:root /etc/systemd/system/update-db-token.service",
      "sudo chown root:root /etc/systemd/system/update-db-token.timer",
      "sudo chmod 644 /etc/systemd/system/docker-compose-app.service",
      "sudo chmod 644 /etc/systemd/system/update-db-token.service",
      "sudo chmod 644 /etc/systemd/system/update-db-token.timer",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable update-db-token.service",
      "sudo systemctl enable update-db-token.timer",
      "sudo systemctl enable docker-compose-app.service"
    ]
  }
}
