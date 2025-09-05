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
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

source "amazon-ebs" "al2" {
  region                  = var.region
  instance_type           = var.instance_type
  ami_name                = "visitor-logs-system:{{var.environment}}"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["137112412989"] # Amazon
    most_recent = true
  }
}

build {
  name    = "docker-compose-app"
  sources = ["source.amazon-ebs.al2"]

  # Install Docker & Docker Compose
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable docker",
      "sudo yum install -y docker git",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",

      # Install Docker Compose plugin (v2)
      "mkdir -p ~/.docker/cli-plugins",
      "curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose",
      "chmod +x ~/.docker/cli-plugins/docker-compose"
    ]
  }

  # Copy your docker-compose.yml into instance
  provisioner "file" {
    source      = "./docker-compose.yml"
    destination = "/home/ec2-user/docker-compose.yml"
  }

  # Set up systemd service to run docker compose on boot
  provisioner "shell" {
    inline = [
      "sudo bash -c 'cat > /etc/systemd/system/docker-compose-app.service <<EOF\n[Unit]\nDescription=Docker Compose App\nRequires=docker.service\nAfter=docker.service\n\n[Service]\nType=oneshot\nRemainAfterExit=yes\nWorkingDirectory=/home/ec2-user\nExecStart=/usr/bin/docker compose up -d\nExecStop=/usr/bin/docker compose down\n\n[Install]\nWantedBy=multi-user.target\nEOF'",

      # Enable and start service
      "sudo systemctl daemon-reload",
      "sudo systemctl enable docker-compose-app.service"
    ]
  }
}
