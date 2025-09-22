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
  }
  ssh_username          = "ec2-user"
}

build {
  name    = "docker-compose-app"
  sources = ["source.amazon-ebs.al2"]

  provisioner "shell" {
    inline = [
      "cat <<EOF > /home/ec2-user/.env",
      "TAG_NAME=${var.tag_name}",
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
    destination = "/home/ec2-user/docker-compose.yml"
  }

  # Copy systemd unit file
  provisioner "file" {
    source      = "./files/docker-compose-app.service"
    destination = "/tmp/docker-compose-app.service"
  }

  # Install and enable systemd service
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/docker-compose-app.service /etc/systemd/system/docker-compose-app.service",
      "sudo chown root:root /etc/systemd/system/docker-compose-app.service",
      "sudo chmod 644 /etc/systemd/system/docker-compose-app.service",
      "sudo systemctl daemon-reload"
    ]
  }
}
