##################################################################################
//////////////////////////////// VPCs ////////////////////////////////////////////
##################################################################################

resource "aws_vpc" "main" {
  for_each   = { for k, v in var.vpc_params : k => v }
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
    type = each.value.type
    vpc  = each.key
  }
}

resource "aws_internet_gateway" "hub" {
  vpc_id = join("", [for v in aws_vpc.main : v.id if v.tags.type == "hub"])
  tags = {
    Name = "${var.net_name}_internet_gateway"
  }
}

##################################################################################
///////////////////////////// Network ACLs ///////////////////////////////////////
##################################################################################

resource "aws_network_acl" "spoke" {
  for_each = {for vpck, vpc in aws_vpc.main : vpck => vpc.id if vpc.tags.type == "spoke"}
  vpc_id = each.value

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags = {
    "Name" = "${var.net_name}_${each.key}_nacl"
  }
}

/* resource "aws_network_acl_rule" "allow_db_in" {
  network_acl_id = aws_network_acl.bar.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.foo.cidr_block
  from_port      = 22
  to_port        = 22
} */

##################################################################################
//////////////////////////////// Subnets /////////////////////////////////////////
##################################################################################

locals {
  hub_subnet_names = {
    "inside"  = 0
    "ha"      = 1
    "outside" = 2
    "mgmt"    = 3
    "tg"      = 4
  }
}

resource "aws_subnet" "hub" {
  for_each                = local.hub_subnet_names
  vpc_id                  = join("", [for v in aws_vpc.main : v.id if v.tags.type == "hub"])
  cidr_block              = cidrsubnet(aws_vpc.main[join("", [for k, v in var.vpc_params : k if v.type == "hub"])].cidr_block, 6, each.value)
  map_public_ip_on_launch = each.value > 1 ? true : false

  tags = {
    Name    = "${var.net_name}_${join("", [for k, v in var.vpc_params : k if v.type == "hub"])}_${each.key}_subnet"
    type    = "hub"
    vpc     = join("", [for k, v in var.vpc_params : k if v.type == "hub"])
    purpose = each.key
  }
}

resource "aws_subnet" "spoke" {
  for_each                = var.subnet_params
  vpc_id                  = aws_vpc.main[each.value.vpc].id
  cidr_block              = cidrsubnet(aws_vpc.main[each.value.vpc].cidr_block, each.value.cidr_mask - tonumber(element(split("/", aws_vpc.main[each.value.vpc].cidr_block), 1)), lookup({ for k, v in keys({ for k, v in var.subnet_params : k => v if v.vpc == each.value.vpc }) : v => k }, each.key))
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${var.net_name}_${each.value.vpc}_${each.key}_subnet"
    vpc  = each.value.vpc
    type = "spoke"
  }
}

resource "aws_subnet" "transit_gateway" {
  for_each   = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  vpc_id     = aws_vpc.main[each.key].id
  cidr_block = cidrsubnet(aws_vpc.main[each.key].cidr_block, tonumber(element(split("/", element(values({ for k, v in aws_subnet.spoke : k => v.cidr_block if v.tags.vpc == each.key }), 0)), 1)) - tonumber(element(split("/", aws_vpc.main[each.key].cidr_block), 1)), length({ for k, v in aws_subnet.spoke : k => v if v.tags.vpc == each.key }))

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
  transit_gateway_cidr_blocks     = [for sub in aws_subnet.hub : sub.cidr_block if sub.tags.purpose == "tg"]
  amazon_side_asn                 = var.tg_params.amazon_side_asn == null ? 64512 : var.tg_params.amazon_side_asn
  dns_support                     = var.tg_params.enable_dns_support == true ? "enable" : "disable"
  multicast_support               = var.tg_params.enable_multicast_support == true ? "enable" : "disable"
  vpn_ecmp_support                = var.tg_params.enable_vpn_ecmp_support == true ? "enable" : "disable"
  auto_accept_shared_attachments  = var.tg_params.auto_accept_shared_attachments == true ? "enable" : "disable"
  default_route_table_association = var.tg_params.default_route_table_association == true ? "enable" : "disable"
  default_route_table_propagation = var.tg_params.default_route_table_propagation == true ? "enable" : "disable"
  tags = {
    Name = var.tg_params.tg_name
  }
}

// ******  Route Tables ***** //
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.trace.id

  tags = {
    Name = "${var.net_name}_spoke_tg_rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.trace.id

  tags = {
    Name = "${var.net_name}_hub_tg_rt"
  }
}

// ******  Routes ***** //
resource "aws_ec2_transit_gateway_route" "spoke_to_hub" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route" "spoke_null" {
  for_each                       = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  destination_cidr_block         = each.value.cidr
  blackhole = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route" "hub_to_spoke" {
  for_each                       = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

// ******  Route table associations ***** //
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each                       = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

// ******  VPC Attachments ***** //
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each                                        = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  subnet_ids                                      = [aws_subnet.transit_gateway[each.key].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.trace.id
  vpc_id                                          = aws_subnet.transit_gateway[each.key].vpc_id
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "${var.net_name}_tg_to_${each.key}_vpc_attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  subnet_ids                                      = [lookup({ for k, v in aws_subnet.hub : k => v.id if length(regexall("${var.net_name}_${join("", [for k, v in var.vpc_params : k if v.type == "hub"])}_tg_subnet", v.tags.Name)) > 0 }, "tg")]
  transit_gateway_id                              = aws_ec2_transit_gateway.trace.id
  vpc_id                                          = join("", [for v in aws_vpc.main : v.id if v.tags.type == "hub"])
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "${var.net_name}_tg_to_hub_vpc_attach"
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

##################################################################################
//////////////////////// Subnet Route Tables /////////////////////////////////////
##################################################################################

resource "aws_route_table" "spoke" {
  for_each = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  vpc_id   = aws_vpc.main[each.key].id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.trace.id
  }

  tags = {
    Name = "${var.net_name}_${each.key}_subnet_rt"
  }
}

resource "aws_route_table_association" "spoke" {
  for_each       = var.subnet_params
  subnet_id      = aws_subnet.spoke[each.key].id
  route_table_id = aws_route_table.spoke[each.value.vpc].id
}

##################################################################################
//////////////////////// Hub Route Tables /////////////////////////////////////
##################################################################################

resource "aws_route_table" "hub" {
  for_each = toset(["internal", "external"])
  vpc_id   = join("", [for v in aws_vpc.main : v.id if v.tags.type == "hub"])

  tags = {
    Name = "${var.net_name}_hub_${each.key}_rt"
  }
}

resource "aws_route_table_association" "internal" {
  for_each       = { for k, v in aws_subnet.hub : v.tags.Name => v if v.tags.purpose == "inside" }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.hub["internal"].id
}

#mgmt, outside, ha
resource "aws_route_table_association" "external" {
  for_each       = { for k, v in aws_subnet.hub : v.tags.Name => v if v.tags.purpose != "inside" && v.tags.purpose != "tg" }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.hub["external"].id
}

resource "aws_route" "route_to_tg" {
  route_table_id         = aws_route_table.hub["internal"].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.trace.id
}

resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.hub["external"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub.id
}

resource "aws_route" "route_to_tg_subnet" {
  for_each               = aws_subnet.transit_gateway
  route_table_id         = aws_route_table.hub["external"].id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.trace.id
}


##################################################################################
////////////////////////   Security Groups  /////////////////////////////////////
##################################################################################

resource "aws_security_group" "spoke" {
  for_each = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  name     = "${var.net_name}_${each.key}_sg"
  vpc_id   = aws_vpc.main[each.key].id

  tags = {
    Name = "${var.net_name}_${each.key}_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_to_dmz" {
  for_each          = { for k, v in var.vpc_params : k => v if k == "app" }
  security_group_id = aws_security_group.spoke[each.key].id
  cidr_ipv4         = join("", [for v in aws_vpc.main : v.cidr_block if v.tags.vpc == "dmz"])
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_to_app" {
  for_each          = { for k, v in var.vpc_params : k => v if v.type == "spoke" && k != "app" }
  security_group_id = aws_security_group.spoke[each.key].id
  cidr_ipv4         = join("", [for v in aws_vpc.main : v.cidr_block if v.tags.vpc == "app"])
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_to_db" {
  for_each          = { for k, v in var.vpc_params : k => v if k == "app" }
  security_group_id = aws_security_group.spoke[each.key].id
  cidr_ipv4         = join("", [for v in aws_vpc.main : v.cidr_block if v.tags.vpc == "db"])
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_from_dmz" {
  for_each          = { for k, v in var.vpc_params : k => v if k == "app" }
  security_group_id = aws_security_group.spoke[each.key].id
  cidr_ipv4         = join("", [for v in aws_vpc.main : v.cidr_block if v.tags.vpc == "dmz"])
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_from_app" {
  for_each          = { for k, v in var.vpc_params : k => v if v.type == "spoke" && k != "app" }
  security_group_id = aws_security_group.spoke[each.key].id
  cidr_ipv4         = join("", [for v in aws_vpc.main : v.cidr_block if v.tags.vpc == "app"])
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_from_db" {
  for_each          = { for k, v in var.vpc_params : k => v if k == "app" }
  security_group_id = aws_security_group.spoke[each.key].id
  cidr_ipv4         = join("", [for v in aws_vpc.main : v.cidr_block if v.tags.vpc == "db"])
  ip_protocol       = "-1"
}

