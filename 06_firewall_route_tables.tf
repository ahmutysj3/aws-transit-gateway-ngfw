
# firewall Route Tables
resource "aws_route_table" "fw_internal" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_internal_route_table"
  }
}

resource "aws_route_table" "fw_external" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_external_route_table"
  }
}

resource "aws_route_table" "fw_tgw" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_tgw_route_table"
  }
}

# Firewall TGW Route Table Associations
resource "aws_route_table_association" "fw_tgw" {
  subnet_id      = aws_subnet.tgw.id
  route_table_id = aws_route_table.fw_tgw.id
}


# Firewall External Route Table Associations
resource "aws_route_table_association" "fw_mgmt" {
  subnet_id      = aws_subnet.fw_mgmt.id
  route_table_id = aws_route_table.fw_external.id
}

resource "aws_route_table_association" "fw_outside" {
  subnet_id      = aws_subnet.fw_outside.id
  route_table_id = aws_route_table.fw_external.id
}

# Firewall Internal Route Table Associations
resource "aws_route_table_association" "fw_inside" {
  subnet_id      = aws_subnet.fw_inside.id
  route_table_id = aws_route_table.fw_internal.id
}

resource "aws_route_table_association" "fw_heartbeat" {
  subnet_id      = aws_subnet.fw_heartbeat.id
  route_table_id = aws_route_table.fw_internal.id
}
