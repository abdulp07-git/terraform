resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project}-igw"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
