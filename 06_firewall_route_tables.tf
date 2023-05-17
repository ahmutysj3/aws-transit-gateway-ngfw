
# firewall Route Tables
resource "aws_route_table" "fw_internal" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_internal_route_table_pri"
  }
}

resource "aws_route_table" "fw_external" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_external_route_table_pri"
  }
}

resource "aws_route_table" "fw_tgw" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_tgw_route_table"
  }
}

# Firewall TGW Route Table Associations
resource "aws_route_table_association" "fw_tgw_pri" {
  subnet_id      = aws_subnet.tgw_pri.id
  route_table_id = aws_route_table.fw_tgw.id
}

resource "aws_route_table_association" "fw_tgw_sec" {
  subnet_id      = aws_subnet.tgw_sec.id
  route_table_id = aws_route_table.fw_tgw.id
}

# Firewall External Route Table Associations
resource "aws_route_table_association" "fw_mgmt_pri" {
  subnet_id      = aws_subnet.fw_mgmt_pri.id
  route_table_id = aws_route_table.fw_external.id
}

resource "aws_route_table_association" "fw_mgmt_sec" {
  subnet_id      = aws_subnet.fw_mgmt_sec.id
  route_table_id = aws_route_table.fw_external.id
}

resource "aws_route_table_association" "fw_outside_pri" {
  subnet_id      = aws_subnet.fw_outside_pri.id
  route_table_id = aws_route_table.fw_external.id
}

resource "aws_route_table_association" "fw_outside_sec" {
  subnet_id      = aws_subnet.fw_outside_sec.id
  route_table_id = aws_route_table.fw_external.id
}

# Firewall Internal Route Table Associations
resource "aws_route_table_association" "fw_inside_pri" {
  subnet_id      = aws_subnet.fw_inside_pri.id
  route_table_id = aws_route_table.fw_internal.id
}

resource "aws_route_table_association" "fw_inside_sec" {
  subnet_id      = aws_subnet.fw_inside_sec.id
  route_table_id = aws_route_table.fw_internal.id
}

resource "aws_route_table_association" "fw_heartbeat_pri" {
  subnet_id      = aws_subnet.fw_heartbeat_pri.id
  route_table_id = aws_route_table.fw_internal.id
}

resource "aws_route_table_association" "fw_heartbeat_sec" {
  subnet_id      = aws_subnet.fw_heartbeat_sec.id
  route_table_id = aws_route_table.fw_internal.id
}