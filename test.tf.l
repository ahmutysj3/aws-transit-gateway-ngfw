# Security VPC
resource "aws_vpc" "firewall_vpc" {
  #depends_on = [aws_cloudwatch_log_group.flow_logs]
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
    Name = "main_igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.firewall_vpc.id
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
  vpc_subnet_map =  {for k, v in var.spoke_vpc_params : k => v.subnets}
  vpc_subnet_count = {for k, v in var.spoke_vpc_params : k => length(v.subnets)}
  values_list = flatten(values(transpose(local.vpc_subnet_map)))
  keys_list = keys(transpose(local.vpc_subnet_map))
  
  subnet_to_vpc_map = zipmap(local.keys_list,local.values_list)
  test_ip = "10.0.0.0/24"
}
# Spoke Subnets
resource "aws_subnet" "spoke" {
  for_each = local.subnet_to_vpc_map
  cidr_block = cidrsubnet(aws_vpc.spoke[each.value].cidr_block, 24 - element(split("/",aws_vpc.spoke[each.value].cidr_block),1),lookup(zipmap(lookup(local.vpc_subnet_map,each.value),range(length(lookup(local.vpc_subnet_map,each.value)))),each.key))
  vpc_id = aws_vpc.spoke[each.value].id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${each.key}_subnet"
  }
}