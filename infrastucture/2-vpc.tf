resource "aws_vpc" "database_vpc" {
  cidr_block = var.vpc_cidr
  # enable_dns_hostnames = true
  # enable_dns_support = true

  tags = var.tags

}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.database_vpc.id
  cidr_block              = var.public_cidrblock_1
  availability_zone       = var.av_zone[0]
  map_public_ip_on_launch = true

  tags = {
    "name" = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.database_vpc.id
  cidr_block              = var.public_cidrblock_2
  availability_zone       = var.av_zone[1]
  map_public_ip_on_launch = true

  tags = {
    "name" = "public_2"
  }
}

# public setup
resource "aws_internet_gateway" "igw_openvpn" {
  vpc_id = aws_vpc.database_vpc.id
  tags   = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.database_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_openvpn.id
  }
  tags = {
    "name" = "public-route"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}
