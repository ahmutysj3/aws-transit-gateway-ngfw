
# firewall Route Tables
resource "aws_route_table" "fw_internal_pri" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_internal_route_table_pri"
  }
}

resource "aws_route_table" "fw_external_pri" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_external_route_table_pri"
  }
}

resource "aws_route_table" "fw_internal_sec" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_internal_route_table_sec"
  }
}

resource "aws_route_table" "fw_external_sec" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_external_route_table_sec"
  }
}

# Firewall Route Table Associations
resource "aws_route_table_association" "fw_inside_pri" {
  subnet_id      = aws_subnet.fw_inside_pri.id
  route_table_id = aws_route_table.fw_internal_pri.id
}

resource "aws_route_table_association" "fw_outside_pri" {
  subnet_id      = aws_subnet.fw_outside_pri.id
  route_table_id = aws_route_table.fw_external_pri.id
}

resource "aws_route_table_association" "fw_mgmt_pri" {
  subnet_id      = aws_subnet.fw_mgmt_pri.id
  route_table_id = aws_route_table.fw_external_pri.id
}

resource "aws_route_table_association" "fw_heartbeat_pri" {
  subnet_id      = aws_subnet.fw_heartbeat_pri.id
  route_table_id = aws_route_table.fw_internal_pri.id
}

resource "aws_route_table_association" "fw_inside_sec" {
  subnet_id      = aws_subnet.fw_inside_sec.id
  route_table_id = aws_route_table.fw_internal_sec.id
}

resource "aws_route_table_association" "fw_outside_sec" {
  subnet_id      = aws_subnet.fw_outside_sec.id
  route_table_id = aws_route_table.fw_external_sec.id
}

resource "aws_route_table_association" "fw_mgmt_sec" {
  subnet_id      = aws_subnet.fw_mgmt_sec.id
  route_table_id = aws_route_table.fw_external_sec.id
}

resource "aws_route_table_association" "fw_heartbeat_sec" {
  subnet_id      = aws_subnet.fw_heartbeat_sec.id
  route_table_id = aws_route_table.fw_internal_sec.id
}