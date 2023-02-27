resource "aws_networkmanager_global_network" "trace" {
  description = "trace's aws wan/global network container"
  tags = {
    Name = "${var.net_name}_global_network"
  }
}

resource "aws_vpc" "hub" {
  for_each = {
    for k, v in var.vpc_params : k => v if v.type == "hub"
  }
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
  }
}

resource "aws_vpc" "spokes" {
  for_each = {
    for k, v in var.vpc_params : k => v if v.type == "spoke"
  }
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
  }
}

resource "aws_subnet" "spokes" {
  for_each                = var.subnet_params
  vpc_id                  = aws_vpc.spokes[each.value.vpc].id
  cidr_block              = cidrsubnet(aws_vpc.spokes[each.value.vpc].cidr_block, each.value.cidr_mask - tonumber(element(split("/", aws_vpc.spokes[each.value.vpc].cidr_block), 1)), lookup({for k,v in keys({for k,v in var.subnet_params : k => v if v.vpc == each.value.vpc}) : v => k}, each.key))
  #cidr_block              = cidrsubnet(aws_vpc.spokes[each.value.vpc].cidr_block, each.value.cidr_mask - lookup(local.combined_vpc_mask, each.value.vpc),lookup(local.combined_net_num, each.key))
  map_public_ip_on_launch = each.value.public
}

resource "aws_ec2_transit_gateway" "trace" {
  description                     = "trace test transit gateway"
  transit_gateway_cidr_blocks     = [var.supernet]
  amazon_side_asn                 = 64512
  dns_support                     = "enable"
  multicast_support               = "enable"
  vpn_ecmp_support                = "enable"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
    Name = "${var.net_name}_transit_gateway"
  }
}

/* resource "aws_ec2_transit_gateway_vpc_attachment" "trace" {
  subnet_ids         = [aws_subnet.example.id]
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = aws_vpc.example.id
} */
