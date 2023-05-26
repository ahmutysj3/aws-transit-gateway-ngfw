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
  
  dynamic "network_interface" {
    iterator = net_int 
    for_each = {for index, subnet in local.firewall_subnets[0] : subnet => index if subnet != "tgw"}

    content {
      device_index = net_int.value
      network_interface_id = aws_network_interface.firewall[net_int.key].id
    }
  }

}

resource "aws_network_interface" "firewall" {
  for_each = {for index, subnet in local.firewall_subnets[0] : subnet => index if subnet != "tgw"}
  subnet_id = aws_subnet.firewall[each.key].id
  security_groups = [aws_security_group.firewall.id]
  source_dest_check = false
  
  tags = {
    Name = "${var.network_prefix}_fw_${each.key}_interface"
  }
}

resource "aws_eip" "fw_outside" {
  for_each = {for index, subnet in local.firewall_subnets[0] : subnet => index if subnet == "outside"}
  tags = {
    Name = "fw_outside_eip"
  }
  associate_with_private_ip = aws_network_interface.firewall[each.key].private_ip
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.firewall[each.key].id
}