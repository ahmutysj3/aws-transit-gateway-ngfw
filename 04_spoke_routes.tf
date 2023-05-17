resource "aws_route" "spoke_a" {
  route_table_id         = aws_route_table.spoke_a_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "spoke_b" {
  route_table_id         = aws_route_table.spoke_b_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}