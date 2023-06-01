# Firewall Instance
resource "aws_instance" "fortigate" {
  availability_zone    = var.availability_zone_list[0]
  ami                  = var.fortigate_ami.id
  instance_type        = var.firewall_defaults.instance_type
  key_name             = "${var.network_prefix}_linux_vm"
  monitoring           = false
  iam_instance_profile = aws_iam_instance_profile.api_call_profile.name
  user_data            = data.template_file.init.rendered

  cpu_options {
    core_count       = 2
    threads_per_core = 2
  }

  dynamic "network_interface" {
    iterator = net_int
    for_each = { for index, subnet in var.firewall_defaults.subnets : subnet => index if subnet != "tgw" }

    content {
      device_index         = net_int.value
      network_interface_id = aws_network_interface.firewall[net_int.key].id
    }
  }

  tags = {
    Name = "${var.network_prefix}_${var.firewall_params.firewall_name}"
  }
}

locals {
  firewall_port_map = { for portk, port in aws_network_interface.firewall : portk => {
    int_ip = join("/", [port.private_ip, cidrnetmask(aws_subnet.firewall[portk].cidr_block)])
    gw_ip  = cidrhost(aws_subnet.firewall[portk].cidr_block, 1)
  } }
  firewall_conf_inputs = {
    fgt_id           = "${var.firewall_params.firewall_name}"
    type             = "payg"
    fgt_inside_ip    = element([for portk, port in local.firewall_port_map : port.int_ip if portk == "inside"], 0)
    fgt_heartbeat_ip = element([for portk, port in local.firewall_port_map : port.int_ip if portk == "heartbeat"], 0)
    fgt_mgmt_ip      = element([for portk, port in local.firewall_port_map : port.int_ip if portk == "mgmt"], 0)
    inside_gw        = element([for portk, port in local.firewall_port_map : port.gw_ip if portk == "inside"], 0)
    spoke1_cidr      = element([ for vpck, vpc in aws_vpc.spoke : vpc.cidr_block if vpck == "public" ], 0 )
    spoke2_cidr      = element([ for vpck, vpc in aws_vpc.spoke : vpc.cidr_block if vpck == "dmz" ], 0 )
    spoke3_cidr      = element([ for vpck, vpc in aws_vpc.spoke : vpc.cidr_block if vpck == "protected" ], 0 )
    mgmt_cidr        = element([ for vpck, vpc in aws_vpc.spoke : vpc.cidr_block if vpck == "management" ], 0 )
    password         = "${var.network_prefix}-${var.network_prefix}"
    mgmt_gw          = element([for portk, port in local.firewall_port_map : port.gw_ip if portk == "mgmt"], 0)
    fgt_priority     = "255"
  }

  firewall_conf_inputs_var = {
    inside_gw        = "10.200.254.65"
    fgt_inside_ip    = "10.200.254.68/255.255.255.192"
    fgt_heartbeat_ip = "10.200.254.132/255.255.255.192"
    fgt_id           = "fortigate_001"
    fgt_mgmt_ip      = "10.200.254.196/255.255.255.192"
    fgt_priority     = "255"
    mgmt_cidr        = "10.200.48.0/20"
    mgmt_gw          = "10.200.254.193"
    password         = "trace-trace"
    spoke1_cidr      = "10.200.0.0/20"
    spoke2_cidr      = "10.200.16.0/20"
    type             = "payg"
  }
}

data "template_file" "init" {
  template = file("./module/fortigate_conf.tpl")
  vars     = local.firewall_conf_inputs
}

output "template_file" {
  value = data.template_file.init
}

# Firewall Network Interfaces
locals {
  inside_extra_ips_list = [for k in range(var.firewall_params.inside_extra_private_ips) : cidrhost(aws_subnet.firewall["inside"].cidr_block, -2 - k)]
  outside_extra_ips_map = { for k, v in range(var.firewall_params.outside_extra_public_ips) : "outside_extra_eip_${k}" => cidrhost(aws_subnet.firewall["outside"].cidr_block, -2 - k) }
}

resource "aws_network_interface" "firewall" {
  for_each                = { for index, subnet in var.firewall_defaults.subnets : subnet => index if subnet != "tgw" }
  subnet_id               = aws_subnet.firewall[each.key].id
  private_ip_list_enabled = true
  private_ip_list         = each.key == "mgmt" || each.key == "heartbeat" ? [cidrhost(aws_subnet.firewall[each.key].cidr_block, 4)] : each.key == "outside" ? concat([cidrhost(aws_subnet.firewall[each.key].cidr_block, 4)], values(local.outside_extra_ips_map)) : concat([cidrhost(aws_subnet.firewall[each.key].cidr_block, 4)], local.inside_extra_ips_list)
  security_groups         = [aws_security_group.firewall.id]
  source_dest_check       = false

  tags = {
    Name = "${var.network_prefix}_fw_${each.key}_interface"
  }
}

# Firewall Elastic IPs - Outside Extra IPs (for NAT)
resource "aws_eip" "outside_extra" {
  for_each                  = local.outside_extra_ips_map
  associate_with_private_ip = each.value
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.firewall["outside"].id

  tags = {
    Name = "${var.network_prefix}_${each.key}"
  }
}

# Firewall Elastic IPs - Primary Outside Interface IP
resource "aws_eip" "firewall" {
  for_each                  = { for index, subnet in var.firewall_defaults.subnets : subnet => index if subnet == "outside" || subnet == "mgmt" }
  associate_with_private_ip = cidrhost(aws_subnet.firewall[each.key].cidr_block, 4)
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.firewall[each.key].id

  tags = {
    Name = "${var.network_prefix}_fw_${each.key}_eip"
  }
}

# IAM instance Profile for Firewall API Calls
resource "aws_iam_instance_profile" "api_call_profile" {
  name = "api_call_profile"
  role = aws_iam_role.api_call_role.name
}

# IAM Role to Allow API Calls by Firewall
resource "aws_iam_role" "api_call_role" {
  name = "${var.network_prefix}_api_call_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# IAM Policy to allow Firewall to move IPs for HA
resource "aws_iam_policy" "api_call_policy" {
  name        = "${var.network_prefix}_api_call_policy"
  path        = "/"
  description = "Policies for the FGT api_call Role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Action": 
            [
              "ec2:Describe*",
              "ec2:AssociateAddress",
              "ec2:AssignPrivateIpAddresses",
              "ec2:UnassignPrivateIpAddresses",
              "ec2:ReplaceRoute"
            ],
            "Resource": "*"
        }
      ]
}
EOF
}

resource "aws_iam_policy_attachment" "api_call_attach" {
  name       = "api_call-attachment"
  roles      = [aws_iam_role.api_call_role.name]
  policy_arn = aws_iam_policy.api_call_policy.arn
}


