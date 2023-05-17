# VPC A Private Subnet
resource "aws_subnet" "spoke_a_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc_a.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "spoke_a_subnet"
  }
}

# VPC B Private Subnet
resource "aws_subnet" "spoke_b_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc_b.id
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "spoke_b_subnet"
  }
}