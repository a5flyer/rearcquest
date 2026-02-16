resource "aws_vpc" "reactf" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "reactf-vpc"
  }
}

resource "aws_subnet" "reactf_public_1" {
  vpc_id                  = aws_vpc.reactf.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "reactf-public-1"
  }
}

resource "aws_subnet" "reactf_public_2" {
  vpc_id                  = aws_vpc.reactf.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "reactf-public-2"
  }
}

resource "aws_internet_gateway" "reactf" {
  vpc_id = aws_vpc.reactf.id

  tags = {
    Name = "reactf-igw"
  }
}

resource "aws_route_table" "reactf" {
  vpc_id = aws_vpc.reactf.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.reactf.id
  }

  tags = {
    Name = "reactf-rt"
  }
}

resource "aws_route_table_association" "reactf_public_1" {
  subnet_id      = aws_subnet.reactf_public_1.id
  route_table_id = aws_route_table.reactf.id
}

resource "aws_route_table_association" "reactf_public_2" {
  subnet_id      = aws_subnet.reactf_public_2.id
  route_table_id = aws_route_table.reactf.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
