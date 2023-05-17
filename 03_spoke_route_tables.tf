
# Spoke VPC Route Tables
resource "aws_route_table" "spoke_a_subnet" {
  vpc_id = aws_vpc.spoke_vpc_a.id

  tags = {
    Name = "spoke_vpc_a_subnet_route_table"
  }
}

resource "aws_route_table" "spoke_b_subnet" {
  vpc_id = aws_vpc.spoke_vpc_b.id

  tags = {
    Name = "spoke_vpc_b_subnet_route_table"
  }
}

# Subnet Route Table Associations
resource "aws_route_table_association" "spoke_a_subnet" {
  subnet_id      = aws_subnet.spoke_a_subnet.id
  route_table_id = aws_route_table.spoke_a_subnet.id
}

resource "aws_route_table_association" "spoke_b_subnet" {
  subnet_id      = aws_subnet.spoke_b_subnet.id
  route_table_id = aws_route_table.spoke_b_subnet.id
}