# Security VPC
resource "aws_vpc" "firewall_vpc" {
  cidr_block = "10.${var.supernet_index}.0.0/24"

  tags = {
    Name = "firewall_vpc"
  }
}

# Spoke VPCs
resource "aws_vpc" "spoke_vpc_a" {
  cidr_block = "10.${var.supernet_index}.1.0/24"

  tags = {
    Name = "spoke_vpc_a"
  }
}

resource "aws_vpc" "spoke_vpc_b" {
  cidr_block = "10.${var.supernet_index}.2.0/24"

  tags = {
    Name = "spoke_vpc_b"
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

# VPC A Private Subnet
resource "aws_subnet" "spoke_a_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc_a.id
  cidr_block              = "10.${var.supernet_index}.1.128/25"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "spoke_a_subnet"
  }
}

# VPC B Private Subnet
resource "aws_subnet" "spoke_b_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc_b.id
  cidr_block              = "10.${var.supernet_index}.2.128/25"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "spoke_b_subnet"
  }
}


# Spoke VPC Route Tables
resource "aws_route_table" "spoke_a_subnet" {
  vpc_id = aws_vpc.spoke_vpc_a.id

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

# Subnet Route Table Associations
resource "aws_route_table_association" "spoke_a_subnet" {
  subnet_id      = aws_subnet.spoke_a_subnet.id
  route_table_id = aws_route_table.spoke_a_subnet.id
}

resource "aws_route_table_association" "spoke_b_subnet" {
  subnet_id      = aws_subnet.spoke_b_subnet.id
  route_table_id = aws_route_table.spoke_b_subnet.id
}

resource "aws_route" "spoke_a" {
  route_table_id         = aws_route_table.spoke_a_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "spoke_b" {
  route_table_id         = aws_route_table.spoke_b_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}


# Firewall Subnets - Primary AZ
resource "aws_subnet" "fw_mgmt" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.${var.supernet_index}.0.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fw_mgmt_subnet"
  }
}

resource "aws_subnet" "fw_inside" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.${var.supernet_index}.0.64/26"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_inside_subnet"
  }
}

resource "aws_subnet" "fw_outside" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.${var.supernet_index}.0.128/26"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  depends_on              = [aws_internet_gateway.main]


  tags = {
    Name = "fw_outside_subnet"
  }
}

resource "aws_subnet" "fw_heartbeat" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.${var.supernet_index}.0.192/26"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name = "fw_heartbeat_subnet"
  }
}

resource "aws_subnet" "tgw" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.${var.supernet_index}.0.224/26"
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

resource "aws_route" "fw_external_spoke_a" {
  route_table_id         = aws_route_table.fw_external.id
  destination_cidr_block = "10.${var.supernet_index}.1.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "fw_external_spoke_b" {
  route_table_id         = aws_route_table.fw_external.id
  destination_cidr_block = "10.${var.supernet_index}.2.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Firewall Internal Route Table Routes
resource "aws_route" "fw_internal_all" {
  route_table_id         = aws_route_table.fw_internal.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Firewall TGW Route Table Routes
resource "aws_route" "tgw_spoke_a" {
  route_table_id         = aws_route_table.fw_tgw.id
  destination_cidr_block = "10.${var.supernet_index}.1.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "tgw_spoke_b" {
  route_table_id         = aws_route_table.fw_tgw.id
  destination_cidr_block = "10.${var.supernet_index}.2.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
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
  transit_gateway_cidr_blocks     = ["10.${var.supernet_index}.14.0/24", "10.${var.supernet_index}.24.0/24"]
  tags = {
    Name = "tgw_main"
  }
}

# Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_a" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.spoke_a_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.spoke_vpc_a.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_b" {
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  subnet_ids                                      = [aws_subnet.spoke_b_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.spoke_vpc_b.id
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

resource "aws_ec2_transit_gateway_route" "spoke_a_null_route" {
  destination_cidr_block         = "10.${var.supernet_index}.1.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "spoke_b_null_route" {
  destination_cidr_block         = "10.${var.supernet_index}.2.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "fw_outside_null_route" {
  destination_cidr_block         = "10.${var.supernet_index}.0.128/26"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  blackhole                      = true
}


resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_a" {
  destination_cidr_block         = "10.${var.supernet_index}.1.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
}

resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_b" {
  destination_cidr_block         = "10.${var.supernet_index}.2.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
}

# Transit Gateway Route Table Associations
resource "aws_ec2_transit_gateway_route_table_association" "spoke_a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
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
  private_ips       = ["10.${var.supernet_index}.10.10"]
  source_dest_check = false

  tags = {
    Name = "fw_mgmt_interface"
  }
}

resource "aws_network_interface" "fw_inside" {
  subnet_id         = aws_subnet.fw_inside.id
  security_groups   = [aws_security_group.firewall.id]
  private_ips       = ["10.${var.supernet_index}.0.74/26"]
  source_dest_check = false
  tags = {
    Name = "fw_inside_interface"
  }
}

resource "aws_network_interface" "fw_outside" {
  subnet_id         = aws_subnet.fw_outside.id
  security_groups   = [aws_security_group.firewall.id]
  private_ips       = ["10.${var.supernet_index}.0.138/26"]
  source_dest_check = false
  tags = {
    Name = "fw_outside_interface"
  }
}

resource "aws_network_interface" "fw_heartbeat" {
  security_groups   = [aws_security_group.firewall.id]
  subnet_id         = aws_subnet.fw_heartbeat.id
  private_ips       = ["10.${var.supernet_index}.0.202/26"]
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
  count = 1
  bucket        = "${var.network_prefix}-vpc-flow-logs"
  force_destroy = true

  tags = {
    Name        = "${var.network_prefix}-vpc-flow-logs"
    Environment = "dev"
  }
}

resource "aws_flow_log" "spoke_vpc_a" {
  count                = 1
  log_destination      = aws_s3_bucket.flow_logs[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.spoke_vpc_a.id
}

resource "aws_flow_log" "spoke_vpc_b" {
  count                = 1
  log_destination      = aws_s3_bucket.flow_logs[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.spoke_vpc_b.id
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

resource "aws_flow_log" "cloud_watch_spoke_vpc_a" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke_vpc_a.id
}

resource "aws_flow_log" "cloud_watch_spoke_vpc_b" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke_vpc_b.id
}

