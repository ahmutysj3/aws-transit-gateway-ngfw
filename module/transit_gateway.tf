# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  depends_on                      = [aws_internet_gateway.main]
  description                     = "Main Transit Gateway"
  amazon_side_asn                 = var.transit_gateway_defaults.amazon_side_asn
  auto_accept_shared_attachments  = var.transit_gateway_defaults.auto_accept_shared_attachments
  default_route_table_association = var.transit_gateway_defaults.default_route_table_association
  default_route_table_propagation = var.transit_gateway_defaults.default_route_table_propagation
  multicast_support               = var.transit_gateway_defaults.multicast_support
  dns_support                     = var.transit_gateway_defaults.dns_support
  vpn_ecmp_support                = var.transit_gateway_defaults.vpn_ecmp_support
  transit_gateway_cidr_blocks     = [aws_subnet.firewall["tgw"].cidr_block]
  tags = {
    Name = "tgw_main"
  }
}

# Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each                                        = aws_vpc.spoke
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [element(flatten(data.aws_subnets.spoke_vpc[each.key].ids), 0)]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = each.value.id

  tags = {
    Name = "${var.network_prefix}_tgw_${each.key}_attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "firewall" {
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.firewall["tgw"].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.firewall.id

  tags = {
    Name = "${var.network_prefix}_tgw_fw_attach"
  }
}

# Transit Gateway Route Tables

resource "aws_ec2_transit_gateway_route_table" "main" {
  for_each           = toset(["spoke", "firewall"])
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.network_prefix}_tgw_${each.key}_rt_table"
  }
}

# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "spoke_to_firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main["spoke"].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall.id
}

resource "aws_ec2_transit_gateway_route" "spoke_null_route" {
  for_each                       = aws_vpc.spoke
  destination_cidr_block         = each.value.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main["spoke"].id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "fw_outside_null_route" {
  for_each                       = { for index, subnet in var.firewall_defaults.subnets : subnet => index if subnet == "outside" }
  destination_cidr_block         = aws_subnet.firewall[each.key].cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main["firewall"].id
  blackhole                      = true
}


resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_subnets" {
  for_each                       = aws_vpc.spoke
  destination_cidr_block         = each.value.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main["firewall"].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
}


# Transit Gateway Route Table Associations
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each                       = aws_vpc.spoke
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main["spoke"].id
}

resource "aws_ec2_transit_gateway_route_table_association" "firewall" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main["firewall"].id
}