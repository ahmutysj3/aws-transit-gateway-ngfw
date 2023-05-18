resource "aws_network_interface" "fw_mgmt" {
  subnet_id         = aws_subnet.fw_mgmt.id
  private_ips       = ["10.0.10.10"]
  source_dest_check = false

  tags = {
    Name = "fw_mgmt_interface"
  }
}

resource "aws_network_interface" "fw_inside" {
  subnet_id         = aws_subnet.fw_inside.id
  private_ips       = ["10.0.11.10"]
  source_dest_check = false
  tags = {
    Name = "fw_inside_interface"
  }
}

resource "aws_network_interface" "fw_outside" {
  subnet_id         = aws_subnet.fw_outside.id
  private_ips       = ["10.0.12.10"]
  source_dest_check = false
  tags = {
    Name = "fw_outside_interface"
  }
}

resource "aws_eip" "fw_outside" {
  tags = {
    Name = "fw_outside_eip"
  }
  depends_on                = [aws_instance.fortigate]
  associate_with_private_ip = "10.0.12.10"
  network_border_group      = var.region_aws
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.fw_outside.id
}

resource "aws_network_interface" "fw_heartbeat" {
  subnet_id         = aws_subnet.fw_heartbeat.id
  private_ips       = ["10.0.13.10"]
  source_dest_check = false
  tags = {
    Name = "fw_heartbeat_interface"
  }
}

resource "aws_instance" "fortigate" {
  tags = {
    Name = "fortigate_instance"
  }
  availability_zone = data.aws_availability_zones.available.names[0]
  ami               = data.aws_ami.fortigate.id
  instance_type     = "c6i.xlarge"
  key_name          = var.ssh_key_name

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
