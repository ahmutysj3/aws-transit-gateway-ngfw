locals {
  spoke_vpcs = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  hub_vpc    = { for k, v in var.vpc_params : k => v if v.type == "hub" }
}

##################################################################################
//////////////////////////////// VPCs ////////////////////////////////////////////
##################################################################################

resource "aws_vpc" "hub" {
  for_each   = local.hub_vpc
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
    type = each.value.type
  }
}

resource "aws_vpc" "spokes" {
  for_each   = local.spoke_vpcs
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
    type = each.value.type
  }
}

##################################################################################
//////////////////////////////// Subnets /////////////////////////////////////////
##################################################################################
locals {
  hub_subnet_names = ["inside", "outside", "mgmt", "ha", "tg"]
}

resource "aws_subnet" "spokes" {
  for_each   = var.subnet_params
  vpc_id     = aws_vpc.spokes[each.value.vpc].id
  cidr_block = cidrsubnet(aws_vpc.spokes[each.value.vpc].cidr_block, each.value.cidr_mask - tonumber(element(split("/", aws_vpc.spokes[each.value.vpc].cidr_block), 1)), lookup({ for k, v in keys({ for k, v in var.subnet_params : k => v if v.vpc == each.value.vpc }) : v => k }, each.key))
  #cidr_block              = cidrsubnet(aws_vpc.spokes[each.value.vpc].cidr_block, each.value.cidr_mask - lookup(local.combined_vpc_mask, each.value.vpc),lookup(local.combined_net_num, each.key))
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${var.net_name}_${each.key}_subnet"
    vpc  = each.value.vpc
    type = "spoke"
  }
}

resource "aws_subnet" "hub" {
  count      = length(local.hub_subnet_names)
  vpc_id     = aws_vpc.hub["hub"].id
  cidr_block = cidrsubnet(aws_vpc.hub["hub"].cidr_block, 6, count.index)

  tags = {
    Name = element(local.hub_subnet_names, count.index)
    type = "hub"
    vpc  = "hub"
  }
}

resource "aws_subnet" "transit_gateway" {
  for_each   = local.spoke_vpcs
  vpc_id     = aws_vpc.spokes[each.key].id
  cidr_block = cidrsubnet(aws_vpc.spokes[each.key].cidr_block, tonumber(element(split("/", element(values({ for k, v in aws_subnet.spokes : k => v.cidr_block if v.tags.vpc == each.key }), 0)), 1)) - tonumber(element(split("/", aws_vpc.spokes[each.key].cidr_block), 1)), length({ for k, v in aws_subnet.spokes : k => v if v.tags.vpc == each.key }))

  tags = {
    Name = "${var.net_name}_${each.key}_tg_subnet"
    vpc  = each.key
    type = "spoke"
  }
}


##################################################################################
//////////////////////// Transit Gateway & attachments ///////////////////////////
##################################################################################

// ****** Transit Gateway ***** //
resource "aws_ec2_transit_gateway" "trace" {
  description                     = "trace test transit gateway"
  transit_gateway_cidr_blocks     = [var.supernet]
  amazon_side_asn                 = 64512
  dns_support                     = "enable"
  multicast_support               = "enable"
  vpn_ecmp_support                = "enable"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "enable"
  tags = {
    Name = "${var.net_name}_transit_gateway"
  }
}

// ******  Route Tables ***** //
resource "aws_ec2_transit_gateway_route_table" "spokes" {
  for_each           = aws_ec2_transit_gateway_vpc_attachment.spokes
  transit_gateway_id = aws_ec2_transit_gateway.trace.id

  tags = {
    "Name" = "${var.net_name}_${each.key}_tg_rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  for_each           = aws_ec2_transit_gateway_vpc_attachment.hub
  transit_gateway_id = aws_ec2_transit_gateway.trace.id

  tags = {
    "Name" = "${var.net_name}_${each.key}_tg_rt"
  }
}

// ******  Routes ***** //
resource "aws_ec2_transit_gateway_route" "spoke_to_hub" {
  for_each                       = local.spoke_vpcs
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub["hub"].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spokes[each.key].id
}

resource "aws_ec2_transit_gateway_route" "hub_to_spokes" {
  for_each                       = local.spoke_vpcs
  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokes[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub["hub"].id
}

// ******  Route table associations ***** //
resource "aws_ec2_transit_gateway_route_table_association" "spokes" {
  for_each                       = aws_ec2_transit_gateway_vpc_attachment.spokes
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokes[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spokes[each.key].id
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  for_each                       = aws_ec2_transit_gateway_vpc_attachment.hub
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub[each.key].id
}

// ******  VPC Attachments ***** //
resource "aws_ec2_transit_gateway_vpc_attachment" "spokes" {
  for_each           = local.spoke_vpcs
  subnet_ids         = [aws_subnet.transit_gateway[each.key].id]
  transit_gateway_id = aws_ec2_transit_gateway.trace.id
  vpc_id             = aws_subnet.transit_gateway[each.key].vpc_id

  tags = {
    Name = "${var.net_name}_tg_to_${each.key}_vpc_attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  for_each           = local.hub_vpc
  subnet_ids         = [aws_subnet.hub[tonumber(lookup({ for k, v in local.hub_subnet_names : v => k }, "tg"))].id]
  transit_gateway_id = aws_ec2_transit_gateway.trace.id
  vpc_id             = aws_vpc.hub[each.key].id

  tags = {
    Name = "${var.net_name}_tg_to_${each.key}_vpc_attach"
  }
}

// ******  Network Manager & TG Registration ***** //
resource "aws_networkmanager_global_network" "trace" {
  description = "trace's aws wan/global network container"
  tags = {
    Name = "${var.net_name}_global_network"
  }
}

resource "aws_networkmanager_transit_gateway_registration" "trace" {
  global_network_id   = aws_networkmanager_global_network.trace.id
  transit_gateway_arn = aws_ec2_transit_gateway.trace.arn
}