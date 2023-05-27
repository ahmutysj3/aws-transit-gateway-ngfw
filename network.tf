# Security VPC
resource "aws_vpc" "firewall_vpc" {
  cidr_block = cidrsubnet(var.supernet_cidr, 7, 127)

  tags = {
    Name = "firewall_vpc"
  }
}

# Spoke VPCs
resource "aws_vpc" "spoke" {
  for_each   = var.spoke_vpc_params
  cidr_block = each.value.cidr_block
  tags = {
    Name = each.key
  }
}

# Security VPC Internet Gateway
resource "aws_internet_gateway" "main" {
  depends_on = [aws_vpc.firewall_vpc]
  tags = {
    Name = "${var.network_prefix}_igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.firewall_vpc.id
}

resource "aws_network_acl_association" "main" {
  for_each = merge(aws_subnet.firewall,aws_subnet.spoke)
  network_acl_id = aws_network_acl.main[each.key].id
  subnet_id = each.value.id
}

resource "aws_network_acl" "main" {
  for_each = merge(aws_subnet.firewall,aws_subnet.spoke)
  vpc_id = each.value.vpc_id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.network_prefix}_${each.key}_acl"
  }
}

resource "aws_security_group" "firewall" {
  depends_on  = [aws_vpc.firewall_vpc]
  name        = "Firewall Allow-All Security Group"
  description = "Allow all traffic to/from the Internet"
  vpc_id      = aws_vpc.firewall_vpc.id


  ingress {
    description = "Allow inbound traffic from the Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic to the Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  vpc_subnet_map        = { for k, v in var.spoke_vpc_params : k => v.subnets }
  vpc_subnet_map_values = flatten(values(transpose(local.vpc_subnet_map)))
  vpc_subnet_map_keys   = keys(transpose(local.vpc_subnet_map))
  subnet_to_vpc_map     = zipmap(local.vpc_subnet_map_keys, local.vpc_subnet_map_values)
}

# Spoke Subnets
resource "aws_subnet" "spoke" { # creates a /24 subnet for each entry in the subnets argument for var.spoke_vpc_params
  for_each                = local.subnet_to_vpc_map
  cidr_block              = cidrsubnet(aws_vpc.spoke[each.value].cidr_block, 24 - element(split("/", aws_vpc.spoke[each.value].cidr_block), 1), lookup(zipmap(lookup(local.vpc_subnet_map, each.value), range(length(lookup(local.vpc_subnet_map, each.value)))), each.key))
  vpc_id                  = aws_vpc.spoke[each.value].id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${each.key}_subnet"
    type = "spoke"
  }
}

# Spoke VPC Route Tables
resource "aws_route_table" "spoke" {
  for_each = aws_vpc.spoke
  vpc_id   = each.value.id

  tags = {
    Name = "${each.key}_route_table"
  }
}

# Subnet Route Table Associations
resource "aws_route_table_association" "spoke" {
  for_each       = aws_subnet.spoke
  subnet_id      = each.value.id
  route_table_id = aws_route_table.spoke[lookup(local.subnet_to_vpc_map, each.key)].id
}

resource "aws_route" "spoke" {
  depends_on             = [aws_ec2_transit_gateway.main]
  for_each               = aws_route_table.spoke
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

locals {
  firewall_subnets      = ["outside", "inside", "mgmt", "heartbeat", "tgw"]
  firewall_route_tables = ["internal", "external", "tgw"]
}

resource "aws_subnet" "firewall" {
  for_each                = { for index, subnet in local.firewall_subnets : subnet => index }
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = each.key == "tgw" ? cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 1, 1) : cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 3, each.value)
  map_public_ip_on_launch = false #each.key == "outside" ? true : false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name     = "${var.network_prefix}_fw_${each.key}_subnet"
    rt_table = each.key == "outside" || each.key == "mgmt" ? "external" : each.key == "inside" || each.key == "heartbeat" ? "internal" : "tgw"
    type = "firewall"
  }
}
resource "aws_route_table" "firewall" {
  for_each = toset(local.firewall_route_tables)
  vpc_id   = aws_vpc.firewall_vpc.id

  tags = {
    Name = "${var.network_prefix}_fw_${each.key}_rt_table"
  }

}

# Firewall External Route Table Associations
resource "aws_route_table_association" "firewall" {
  for_each       = { for index, subnet in local.firewall_subnets : subnet => index }
  subnet_id      = aws_subnet.firewall[each.key].id
  route_table_id = aws_route_table.firewall[aws_subnet.firewall[each.key].tags.rt_table].id
}

# Firewall TGW Route Table Routes
resource "aws_route" "tgw_spoke" {
  for_each               = var.spoke_vpc_params
  depends_on             = [aws_ec2_transit_gateway.main]
  route_table_id         = aws_route_table.firewall["tgw"].id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "firewall" {
  for_each               = toset(["internal", "external"])
  route_table_id         = aws_route_table.firewall[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = each.key == "external" ? aws_internet_gateway.main.id : null
  transit_gateway_id     = each.key == "internal" ? aws_ec2_transit_gateway.main.id : null
}