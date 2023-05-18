resource "aws_network_interface" "fw_mgmt_pri" {
  subnet_id         = aws_subnet.fw_mgmt_pri.id
  private_ips       = ["10.0.10.10"]
  source_dest_check = false

  tags = {
    Name = "fw_mgmt_interface_pri"
  }
}

resource "aws_network_interface" "fw_inside_pri" {
  subnet_id         = aws_subnet.fw_inside_pri.id
  private_ips       = ["10.0.11.10"]
  source_dest_check = false
  tags = {
    Name = "fw_inside_interface_pri"
  }
}

resource "aws_network_interface" "fw_outside_pri" {
  subnet_id         = aws_subnet.fw_outside_pri.id
  private_ips       = ["10.0.12.10"]
  source_dest_check = false
  tags = {
    Name = "fw_outside_interface_pri"
  }
}

resource "aws_eip" "fw_outside_pri" {
  tags = {
    Name = "fw_outside_eip_pri"
  }
  depends_on                = [aws_instance.fortigate_pri]
  associate_with_private_ip = "10.0.12.10"
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.fw_outside_pri.id
}

resource "aws_network_interface" "fw_heartbeat_pri" {
  subnet_id         = aws_subnet.fw_heartbeat_pri.id
  private_ips       = ["10.0.13.10"]
  source_dest_check = false
  tags = {
    Name = "fw_heartbeat_interface_pri"
  }
}

resource "aws_instance" "fortigate_pri" {
  tags = {
    Name = "fortigate_instance_pri"
  }
  availability_zone = data.aws_availability_zones.available.names[0]
  ami               = data.aws_ami.fortigate.id
  instance_type     = "c6i.xlarge"
  key_name          = var.ssh_key_name

  network_interface {
    network_interface_id = aws_network_interface.fw_outside_pri.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_inside_pri.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_mgmt_pri.id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.fw_heartbeat_pri.id
    device_index         = 3
  }

}
