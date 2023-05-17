# Firewall External Route Table Routes
resource "aws_route" "fw_external_inet" {
  route_table_id         = aws_route_table.fw_external_pri.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "fw_external_spoke_a" {
  route_table_id         = aws_route_table.fw_external_pri.id
  destination_cidr_block = "10.1.1.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "fw_external_spoke_b" {
  route_table_id         = aws_route_table.fw_external_pri.id
  destination_cidr_block = "10.2.1.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}