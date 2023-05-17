
# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Main Transit Gateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  multicast_support               = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  transit_gateway_cidr_blocks     = ["10.0.14.0/24", "10.0.24.0/24"]
  tags = {
    Name = "tgw_main"
  }
}

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

resource "aws_ec2_transit_gateway_route" "fw_outside_pri_null_route" {
  destination_cidr_block         = "10.0.12.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "fw_outside_sec_null_route" {
  destination_cidr_block         = "10.0.22.0/24"
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

# Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_a" {
  subnet_ids         = [aws_subnet.spoke_a_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.spoke_vpc_a.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_b" {
  subnet_ids         = [aws_subnet.spoke_b_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.spoke_vpc_b.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "firewall" {
  subnet_ids         = [aws_subnet.tgw_pri.id, aws_subnet.tgw_sec.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.firewall_vpc.id
}