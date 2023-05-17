# Spoke VPCs
resource "aws_vpc" "vpc_a" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "vpc_a"
  }
}

resource "aws_vpc" "vpc_b" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "vpc_b"
  }
}

# Security VPC
resource "aws_vpc" "vpc_sec" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_sec"
  }
}

# VPC A Private Subnet
resource "aws_subnet" "vpc_a" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "vpc_a_subnet"
  }
}

# VPC B Private Subnet
resource "aws_subnet" "vpc_b" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "vpc_b_subnet"
  }
}

# Firewall Subnets - Primary AZ
resource "aws_subnet" "fw_mgmt_pri" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fw_mgmt_subnet_pri"
  }
}

resource "aws_subnet" "fw_inside_pri" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_inside_subnet_pri"
  }
}

resource "aws_subnet" "fw_outside_pri" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]



  tags = {
    Name = "fw_outside_subnet_pri"
  }
}

resource "aws_subnet" "fw_heartbeat_pri" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.14.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_heartbeat_subnet_pri"
  }
}

resource "aws_subnet" "tgw_pri" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.254.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tgw_subnet_pri"
  }
}

# Firewall Subnets - Secondary AZ
resource "aws_subnet" "fw_mgmt_sec" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fw_mgmt_subnet_sec"
  }
}

resource "aws_subnet" "fw_inside_sec" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.22.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "fw_inside_subnet_sec"
  }
}

resource "aws_subnet" "fw_outside_sec" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.23.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fw_outside_subnet_sec"
  }
}

resource "aws_subnet" "fw_heartbeat_sec" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.24.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "fw_heartbeat_subnet_sec"
  }
}

resource "aws_subnet" "tgw_sec" {
  vpc_id                  = aws_vpc.vpc_sec.id
  cidr_block              = "10.0.255.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "tgw_subnet_sec"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}