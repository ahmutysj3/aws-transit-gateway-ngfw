# Spoke VPCs
resource "aws_vpc" "vpc_a" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "vpc_a"
  }
}

resource "aws_vpc" "vpc_b" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "vpc_b"
  }
}

# Security VPC
resource "aws_vpc" "vpc_sec" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_sec"
  }
}

# VPC A Private Subnet
resource "aws_subnet" "vpc_a" {
  vpc_id     = aws_vpc.vpc_a.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "vpc_a_subnet"
  }
}

# VPC B Private Subnet
resource "aws_subnet" "vpc_b" {
  vpc_id     = aws_vpc.vpc_b.id
  cidr_block = "10.2.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "vpc_b_subnet"
  }
}
