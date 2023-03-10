##################################################################################
//////////////////////////////// VPCs ////////////////////////////////////////////
##################################################################################

resource "aws_vpc" "main" {
  for_each   = { for k, v in var.vpc_params : k => v }
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
    type = each.value.type
  }
}

resource "aws_internet_gateway" "hub" {
  vpc_id = join("", [for v in aws_vpc.main : v.id if v.tags.type == "hub"])
  tags = {
    Name = "${var.net_name}_internet_gateway"
  }
}

##################################################################################
//////////////////////////////// Subnets /////////////////////////////////////////
##################################################################################
locals {
  hub_subnet_names = {
    "inside"  = 0
    "outside" = 1
    "mgmt"    = 2
    "ha"      = 3
    "tg"      = 4
  }
}

resource "aws_subnet" "hub" {
  for_each = local.hub_subnet_names
  vpc_id                  = join("", [for v in aws_vpc.main : v.id if v.tags.type == "hub"])
  cidr_block              = cidrsubnet(aws_vpc.main[join("", [for k, v in var.vpc_params : k if v.type == "hub"])].cidr_block, 6, each.value)
  map_public_ip_on_launch = each.value > 0 ? true : false

  tags = {
    Name = "${var.net_name}_${each.key}_subnet"
    type = "hub"
    vpc  = join("", [for k, v in var.vpc_params : k if v.type == "hub"])
  }
}

resource "aws_subnet" "spokes" {
  for_each   = var.subnet_params
  vpc_id     = aws_vpc.main[each.value.vpc].id
  cidr_block = cidrsubnet(aws_vpc.main[each.value.vpc].cidr_block, each.value.cidr_mask - tonumber(element(split("/", aws_vpc.main[each.value.vpc].cidr_block), 1)), lookup({ for k, v in keys({ for k, v in var.subnet_params : k => v if v.vpc == each.value.vpc }) : v => k }, each.key))
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${var.net_name}_${each.key}_subnet"
    vpc  = each.value.vpc
    type = "spoke"
  }
}

resource "aws_subnet" "transit_gateway" {
  for_each   = { for k, v in var.vpc_params : k => v if v.type == "spoke" }
  vpc_id     = aws_vpc.main[each.key].id
  cidr_block = cidrsubnet(aws_vpc.main[each.key].cidr_block, tonumber(element(split("/", element(values({ for k, v in aws_subnet.spokes : k => v.cidr_block if v.tags.vpc == each.key }), 0)), 1)) - tonumber(element(split("/", aws_vpc.main[each.key].cidr_block), 1)), length({ for k, v in aws_subnet.spokes : k => v if v.tags.vpc == each.key }))

  tags = {
    Name = "${var.net_name}_${each.key}_tg_subnet"
    vpc  = each.key
    type = "spoke"
  }
}