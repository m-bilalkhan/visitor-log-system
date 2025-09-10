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

variable "db_host"      { type = string }
variable "db_port"      { type = string }
variable "db_name"      { type = string }
variable "db_user"      { type = string }
variable "db_password"  { type = string }
variable "tag_name"     { type = string }

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

  # Create .env file for environment variables
  provisioner "shell" {
    inline = [
      "cat <<EOF > /home/ec2-user/.env",
      "DB_HOST=${var.db_host}",
      "DB_PORT=${var.db_port}",
      "DB_NAME=${var.db_name}",
      "DB_USER=${var.db_user}",
      "DB_PASSWORD=${var.db_password}",
      "TAG_NAME=${var.tag_name}",
      "EOF"
    ]
  }

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
