resource "aws_instance" "fortigate" {
  tags = {
    Name = "fortigate_instance"
  }
  availability_zone    = data.aws_availability_zones.available.names[0]
  ami                  = data.aws_ami.fortigate.id
  instance_type        = "c6i.xlarge"
  key_name             = var.ssh_key_name
  monitoring           = false
  iam_instance_profile = aws_iam_instance_profile.api_call_profile.name

  cpu_options {
    core_count       = 2
    threads_per_core = 2
  }

  dynamic "network_interface" {
    iterator = net_int
    for_each = { for index, subnet in local.firewall_subnets[0] : subnet => index if subnet != "tgw" }

    content {
      device_index         = net_int.value
      network_interface_id = aws_network_interface.firewall[net_int.key].id
    }
  }

}

resource "aws_network_interface" "firewall" {
  for_each          = { for index, subnet in local.firewall_subnets[0] : subnet => index if subnet != "tgw" }
  subnet_id         = aws_subnet.firewall[each.key].id
  security_groups   = [aws_security_group.firewall.id]
  source_dest_check = false

  tags = {
    Name = "${var.network_prefix}_fw_${each.key}_interface"
  }
}

resource "aws_eip" "fw_outside" {
  for_each = { for index, subnet in local.firewall_subnets[0] : subnet => index if subnet == "outside" }
  tags = {
    Name = "fw_outside_eip"
  }
  associate_with_private_ip = aws_network_interface.firewall[each.key].private_ip
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.firewall[each.key].id
}

resource "aws_iam_instance_profile" "api_call_profile" {
  name = "api_call_profile"
  role = aws_iam_role.api_call_role.name
}

resource "aws_iam_role" "api_call_role" {
  name = "${var.network_prefix}api_call_role"

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

resource "aws_iam_policy" "api_call_policy" {
  name        = "${var.network_prefix}api_call_policy"
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
