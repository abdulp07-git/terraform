resource "aws_subnet" "public" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${each.key}"
    Environment = var.environment
    Project     = var.project
    Type        = "public"
    ManagedBy   = "Terraform"
  }
}
