resource "aws_vpc" "main" {
  for_each = var.vpc_params
  cidr_block = each.value.cidr
  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
  }
} 

resource "aws_subnet" "spokes" {
  for_each = var.subnet_params
  vpc_id = aws_vpc.main[each.value.vpc].id
  cidr_block = cidrsubnet(aws_vpc.main[each.value.vpc].cidr_block, each.value.cidr_mask - local.app_vpc_mask,lookup(local.combined_net_num,each.key))
  map_public_ip_on_launch = each.value.public
}

# creates a map of subnet params with filter on vpc name
locals { 
  app_subnets = { for k, v in var.subnet_params: k => v if v.vpc == "app"}
  dmz_subnets = { for k, v in var.subnet_params: k => v if v.vpc == "dmz"}
  db_subnets = { for k, v in var.subnet_params: k => v if v.vpc == "db"}
}

# creates a map of subnet name to net bit number for cidrsubnet function
locals {
  app_net_num = {for k, v in keys(local.app_subnets) : v => k}
  dmz_net_num = {for k, v in keys(local.dmz_subnets) : v => k}
  db_net_num = {for k, v in keys(local.db_subnets) : v => k}
}

locals {
  app_vpc_mask = tonumber(element(split("/", aws_vpc.main["app"].cidr_block),1))
  dmz_vpc_mask = tonumber(element(split("/", aws_vpc.main["dmz"].cidr_block),1))
  db_vpc_mask = tonumber(element(split("/", aws_vpc.main["db"].cidr_block),1))
}

locals {
  combined_net_num = merge({for k, v in keys(local.app_subnets) : v => k},{for k, v in keys(local.dmz_subnets) : v => k},{for k, v in keys(local.db_subnets) : v => k})
}