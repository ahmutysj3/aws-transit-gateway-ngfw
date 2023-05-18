
# Firewall Subnets - Primary AZ
resource "aws_subnet" "fw_mgmt" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fw_mgmt_subnet"
  }
}

resource "aws_subnet" "fw_inside" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_inside_subnet"
  }
}

resource "aws_subnet" "fw_outside" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  depends_on              = [aws_internet_gateway.main]


  tags = {
    Name = "fw_outside_subnet"
  }
}

resource "aws_subnet" "fw_heartbeat" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_heartbeat_subnet"
  }
}

resource "aws_subnet" "tgw" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.14.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tgw_subnet"
  }
}