# Security VPC
resource "aws_vpc" "firewall_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "firewall_vpc"
  }
}

# Spoke VPCs
resource "aws_vpc" "spoke_vpc_a" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "spoke_vpc_a"
  }
}

resource "aws_vpc" "spoke_vpc_b" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "spoke_vpc_b"
  }
}

# Security VPC Internet Gateway
resource "aws_internet_gateway" "main" {
  tags = {
    Name = "main_igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.firewall_vpc.id
}



