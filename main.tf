# Security VPC
resource "aws_vpc" "hub_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hub_vpc"
  }
}

# Spoke VPCs
resource "aws_vpc" "spoke_vpc_a" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "spoke_vpc_a"
  }
}

resource "aws_vpc" "spoke_vpc_b" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "spoke_vpc_b"
  }
}

# Security VPC Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.hub_vpc.id

  tags = {
    Name = "hub_vpc_igw"
  }
}

# VPC A Private Subnet
resource "aws_subnet" "spoke_a_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc_a.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "spoke_a_subnet"
  }
}

# VPC B Private Subnet
resource "aws_subnet" "spoke_b_subnet" {
  vpc_id                  = aws_vpc.spoke_spoke_vpc_b.id
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "spoke_b_subnet"
  }
}

# Firewall Subnets - Primary AZ
resource "aws_subnet" "fw_mgmt_pri" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fw_mgmt_subnet_pri"
  }
}

resource "aws_subnet" "fw_inside_pri" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_inside_subnet_pri"
  }
}

resource "aws_subnet" "fw_outside_pri" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]



  tags = {
    Name = "fw_outside_subnet_pri"
  }
}

resource "aws_subnet" "fw_heartbeat_pri" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_heartbeat_subnet_pri"
  }
}

resource "aws_subnet" "tgw_pri" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.14.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tgw_subnet_pri"
  }
}

# Firewall Subnets - Secondary AZ
resource "aws_subnet" "fw_mgmt_sec" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fw_mgmt_subnet_sec"
  }
}

resource "aws_subnet" "fw_inside_sec" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "fw_inside_subnet_sec"
  }
}

resource "aws_subnet" "fw_outside_sec" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.22.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fw_outside_subnet_sec"
  }
}

resource "aws_subnet" "fw_heartbeat_sec" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.23.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "fw_heartbeat_subnet_sec"
  }
}

resource "aws_subnet" "tgw_sec" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.24.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "tgw_subnet_sec"
  }
}

# Data Sources - Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Spoke VPC Route Tables
resource "aws_route_table" "spoke_a_subnet" {
  vpc_id = aws_vpc.spoke_baws_subnet.spoke_b.id

  tags = {
    Name = "spoke_vpc_a_subnet_route_table"
  }
}

resource "aws_route_table" "spoke_b_subnet" {
  vpc_id = aws_vpc.spoke_vpc_b.id

  tags = {
    Name = "spoke_vpc_b_subnet_route_table"
  }
}

# Firewall Route Tables
resource "aws_route_table" "fw_internal_pri" {
  vpc_id = aws_vpc.hub_vpc.id

  tags = {
    Name = "fw_internal_route_table_pri"
  }
}

resource "aws_route_table" "fw_external_pri" {
  vpc_id = aws_vpc.hub_vpc.id

  tags = {
    Name = "fw_external_route_table_pri"
  }
}

resource "aws_route_table_association" "fw_inside_pri" {
  subnet_id      = aws_subnet.fw_inside_pri.id
  route_table_id = aws_route_table.fw_internal_pri.id
}

resource "aws_route_table_association" "fw_outside_pri" {
  subnet_id      = aws_subnet.fw_outside_pri.id
  route_table_id = aws_route_table.fw_external_pri.id
}

resource "aws_route_table_association" "fw_mgmt_pri" {
  subnet_id      = aws_subnet.fw_mgmt_pri.id
  route_table_id = aws_route_table.fw_external_pri.id
}

resource "aws_route_table_association" "fw_heartbeat_pri" {
  subnet_id      = aws_subnet.fw_heartbeat_pri.id
  route_table_id = aws_route_table.fw_internal_pri.id
}

resource "aws_route_table_association" "fw_inside_sec" {
  subnet_id      = aws_subnet.fw_inside_sec.id
  route_table_id = aws_route_table.fw_internal_sec.id
}

resource "aws_route_table_association" "fw_outside_sec" {
  subnet_id      = aws_subnet.fw_outside_sec.id
  route_table_id = aws_route_table.fw_external_sec.id
}

resource "aws_route_table_association" "fw_mgmt_sec" {
  subnet_id      = aws_subnet.fw_mgmt_sec.id
  route_table_id = aws_route_table.fw_external_sec.id
}

resource "aws_route_table_association" "fw_heartbeat_sec" {
  subnet_id      = aws_subnet.fw_heartbeat_sec.id
  route_table_id = aws_route_table.fw_internal_sec.id
}

resource "aws_route_table_association" "spoke_a_subnet" {
  subnet_id      = aws_subnet.spoke_b.id
  route_table_id = aws_route_table.spoke_a_subnet.id
}

resource "aws_route_table_association" "spoke_b_subnet" {
  subnet_id      = aws_subnet.spoke_vpc_b.id
  route_table_id = aws_route_table.spoke_b_subnet.id
}

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

resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}
