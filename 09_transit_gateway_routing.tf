# Transit Gateway Route Tables
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "tgw_spoke_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "firewall" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "tgw_firewall_route_table"
  }
}

# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "spoke_to_firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall.id
}

resource "aws_ec2_transit_gateway_route" "spoke_a_null_route" {
  destination_cidr_block         = "10.1.1.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "spoke_b_null_route" {
  destination_cidr_block         = "10.2.1.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "fw_outside_null_route" {
  destination_cidr_block         = "10.0.12.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  blackhole                      = true
}


resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_a" {
  destination_cidr_block         = "10.1.1.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
}

resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_b" {
  destination_cidr_block         = "10.2.1.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
}

# Transit Gateway Route Table Associations
resource "aws_ec2_transit_gateway_route_table_association" "spoke_a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "firewall" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}