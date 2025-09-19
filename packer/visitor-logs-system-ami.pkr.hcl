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

source "amazon-ebs" "al2" {
  communicator            = "ssh" 
  region                  = var.region
  instance_type           = var.instance_type
  ami_name                = "visitor-log-system-${var.tag_name}"
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
    Name        = "visitor-log-system-${var.environment}"
    Environment = "${var.environment}"
    Project     = "visitor-log-system"
    Owner       = "bilal"
    BuildTime   = "{{timestamp}}"
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

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable docker",
      "sudo yum install -y docker git",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",

      # Install Docker Compose plugin (v2)
      "sudo -u ec2-user mkdir -p /home/ec2-user/.docker/cli-plugins",
      "sudo -u ec2-user curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o /home/ec2-user/.docker/cli-plugins/docker-compose",
      "sudo chmod +x /home/ec2-user/.docker/cli-plugins/docker-compose"

    ]
  }

  provisioner "file" {
    source      = "./../docker-compose.yml"
    destination = "/home/ec2-user/docker-compose.yml"
  }

  provisioner "shell" {
    inline = [
      "sudo bash -c 'cat > /etc/systemd/system/docker-compose-app.service <<EOF\n[Unit]\nDescription=Docker Compose App\nRequires=docker.service\nAfter=docker.service\n\n[Service]\nType=oneshot\nRemainAfterExit=yes\nWorkingDirectory=/home/ec2-user\nExecStart=/usr/bin/docker compose up -d\nExecStop=/usr/bin/docker compose down\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
      # Enable service
      "sudo systemctl daemon-reload",
    ]
  }
}
