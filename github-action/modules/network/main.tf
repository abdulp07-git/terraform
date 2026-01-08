resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name = var.vpc-name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc-name}-igw"
  }
}

resource "aws_subnet" "main" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.pub1-cidr
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.vpc-name}-pubrt"
  }
}

resource "aws_route_table_association" "main" {
  for_each       = aws_subnet.main
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
