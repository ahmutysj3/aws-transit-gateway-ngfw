
# Firewall Subnets - Primary AZ
resource "aws_subnet" "fw_mgmt_pri" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fw_mgmt_subnet_pri"
  }
}

resource "aws_subnet" "fw_inside_pri" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_inside_subnet_pri"
  }
}

resource "aws_subnet" "fw_outside_pri" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]



  tags = {
    Name = "fw_outside_subnet_pri"
  }
}

resource "aws_subnet" "fw_heartbeat_pri" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_heartbeat_subnet_pri"
  }
}

resource "aws_subnet" "tgw_pri" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.14.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tgw_subnet_pri"
  }
}

# Firewall Subnets - Secondary AZ
resource "aws_subnet" "fw_mgmt_sec" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fw_mgmt_subnet_sec"
  }
}

resource "aws_subnet" "fw_inside_sec" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "fw_inside_subnet_sec"
  }
}

resource "aws_subnet" "fw_outside_sec" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.22.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fw_outside_subnet_sec"
  }
}

resource "aws_subnet" "fw_heartbeat_sec" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.23.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "fw_heartbeat_subnet_sec"
  }
}

resource "aws_subnet" "tgw_sec" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.24.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "tgw_subnet_sec"
  }
}