
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

# Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_a" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.spoke_a_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.spoke_vpc_a.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_b" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.spoke_b_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.spoke_vpc_b.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "firewall" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.tgw.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.firewall_vpc.id
}