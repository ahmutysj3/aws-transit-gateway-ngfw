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
  vpc_id = aws_vpc.main["sec"].id
  tags = {
    Name = "${var.net_name}_internet_gateway"
  }
}
