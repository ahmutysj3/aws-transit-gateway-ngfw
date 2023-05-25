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

# Spoke VPC Route Tables
resource "aws_route_table" "spoke" {
  for_each = aws_vpc.spoke
  vpc_id = each.value.id

  tags = {
    Name = "${each.key}_route_table"
  }
}

# Subnet Route Table Associations
resource "aws_route_table_association" "spoke" {
    for_each = aws_subnet.spoke
  subnet_id      = each.value.id
  route_table_id = aws_route_table.spoke[lookup(local.subnet_to_vpc_map,each.key)].id
}

/* resource "aws_route" "spoke" {
    depends_on = [ aws_ec2_transit_gateway.main ]
  for_each = aws_route_table.spoke
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
} */


# Firewall Subnets - Primary AZ
resource "aws_subnet" "fw_mgmt" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 3, 0)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fw_mgmt_subnet"
  }
}

resource "aws_subnet" "fw_inside" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 3, 1)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_inside_subnet"
  }
}

resource "aws_subnet" "fw_outside" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 3, 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  depends_on              = [aws_internet_gateway.main]


  tags = {
    Name = "fw_outside_subnet"
  }
}

resource "aws_subnet" "fw_heartbeat" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 3, 3)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_heartbeat_subnet"
  }
}

resource "aws_subnet" "tgw" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.firewall_vpc.cidr_block, 1, 1)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tgw_subnet"
  }
}

# firewall Route Tables
resource "aws_route_table" "fw_internal" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_internal_route_table"
  }
}

resource "aws_route_table" "fw_external" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_external_route_table"
  }
}

resource "aws_route_table" "fw_tgw" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "fw_tgw_route_table"
  }
}

# Firewall TGW Route Table Associations
resource "aws_route_table_association" "fw_tgw" {
  subnet_id      = aws_subnet.tgw.id
  route_table_id = aws_route_table.fw_tgw.id
}


# Firewall External Route Table Associations
resource "aws_route_table_association" "fw_mgmt" {
  subnet_id      = aws_subnet.fw_mgmt.id
  route_table_id = aws_route_table.fw_external.id
}

resource "aws_route_table_association" "fw_outside" {
  subnet_id      = aws_subnet.fw_outside.id
  route_table_id = aws_route_table.fw_external.id
}

# Firewall Internal Route Table Associations
resource "aws_route_table_association" "fw_inside" {
  subnet_id      = aws_subnet.fw_inside.id
  route_table_id = aws_route_table.fw_internal.id
}

resource "aws_route_table_association" "fw_heartbeat" {
  subnet_id      = aws_subnet.fw_heartbeat.id
  route_table_id = aws_route_table.fw_internal.id
}


# Firewall External Route Table Routes
resource "aws_route" "fw_external_inet" {
  route_table_id         = aws_route_table.fw_external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


# Firewall Internal Route Table Routes
resource "aws_route" "fw_internal_all" {
  depends_on = [ aws_ec2_transit_gateway.main ]
  route_table_id         = aws_route_table.fw_internal.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Firewall TGW Route Table Routes
resource "aws_route" "tgw_spoke" {
  depends_on = [ aws_ec2_transit_gateway.main ]
  for_each = aws_vpc.spoke
  route_table_id         = aws_route_table.fw_tgw.id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  depends_on = [ aws_vpc.firewall_vpc ]
  description                     = "Main Transit Gateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  multicast_support               = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  transit_gateway_cidr_blocks     = [aws_subnet.tgw.cidr_block]
  tags = {
    Name = "tgw_main"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  vpc_id = aws_vpc.spoke["protected"].id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  subnet_ids = [aws_subnet.spoke["vault"].id]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}
/*
# Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
for_each = aws_vpc.spoke
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [flatten(data.aws_subnets.spoke_vpc[each.key].ids)]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = each.value.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "firewall" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.tgw.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.firewall_vpc.id
}

# Transit Gateway Route Tables
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "tgw_spoke_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "firewall" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "tgw_firewall_route_table"
  }
}

# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "spoke_to_firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall.id
}

resource "aws_ec2_transit_gateway_route" "spoke_null_route" {
  for_each = aws_vpc.spoke
  destination_cidr_block         = each.value.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "fw_outside_null_route" {
  destination_cidr_block         = aws_subnet.fw_outside.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  blackhole                      = true
}


resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_subnets" {
    for_each = aws_vpc.spoke
  destination_cidr_block         = each.value.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
}


# Transit Gateway Route Table Associations
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
    for_each = aws_vpc.spoke
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "firewall" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}

resource "aws_instance" "fortigate" {
  tags = {
    Name = "fortigate_instance"
  }
  availability_zone = data.aws_availability_zones.available.names[0]
  ami               = data.aws_ami.fortigate.id
  instance_type     = "c6i.xlarge"
  key_name          = var.ssh_key_name
  monitoring        = false



  cpu_options {
    core_count       = 2
    threads_per_core = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_outside.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_inside.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_mgmt.id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_heartbeat.id
    device_index         = 3
  }

}

resource "aws_network_interface" "fw_mgmt" {
  subnet_id         = aws_subnet.fw_mgmt.id
  security_groups   = [aws_security_group.firewall.id]
  private_ips       = [cidrhost(aws_subnet.fw_mgmt.cidr_block, 10)]
  source_dest_check = false

  tags = {
    Name = "fw_mgmt_interface"
  }
}

resource "aws_network_interface" "fw_inside" {
  subnet_id         = aws_subnet.fw_inside.id
  security_groups   = [aws_security_group.firewall.id]
  private_ips       = [cidrhost(aws_subnet.fw_inside.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "fw_inside_interface"
  }
}

resource "aws_network_interface" "fw_outside" {
  subnet_id         = aws_subnet.fw_outside.id
  security_groups   = [aws_security_group.firewall.id]
  private_ips       = [cidrhost(aws_subnet.fw_outside.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "fw_outside_interface"
  }
}

resource "aws_network_interface" "fw_heartbeat" {
  security_groups   = [aws_security_group.firewall.id]
  subnet_id         = aws_subnet.fw_heartbeat.id
  private_ips       = [cidrhost(aws_subnet.fw_heartbeat.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "fw_heartbeat_interface"
  }
}

resource "aws_eip" "fw_outside" {
  tags = {
    Name = "fw_outside_eip"
  }
  depends_on                = [aws_instance.fortigate]
  associate_with_private_ip = aws_network_interface.fw_outside.private_ip
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.fw_outside.id
}

resource "aws_s3_bucket" "flow_logs" {
  count         = 1
  bucket        = "${var.network_prefix}-vpc-flow-logs"
  force_destroy = true

  tags = {
    Name        = "${var.network_prefix}-vpc-flow-logs"
    Environment = "dev"
  }
}

resource "aws_flow_log" "spoke" {
  for_each = aws_vpc.spoke
  log_destination      = aws_s3_bucket.flow_logs[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = each.value.id
}

resource "aws_flow_log" "firewall_vpc" {
  count                = 1
  log_destination      = aws_s3_bucket.flow_logs[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.firewall_vpc.id
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name         = "${var.network_prefix}_flow_log_grp"
  skip_destroy = false
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role" "flow_logs" {
  name               = "${var.network_prefix}_flow_log_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${var.network_prefix}_flow_log_iam_policy"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "cloud_watch_firewall_vpc" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.firewall_vpc.id
}

resource "aws_flow_log" "cloud_watch_spoke" {
  for_each = aws_vpc.spoke
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = each.value.id
}
*/