# Data source to get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "k8s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name        = "${var.instance_name}-root-volume"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
    NodeType    = var.node_type
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = false
  }
}
