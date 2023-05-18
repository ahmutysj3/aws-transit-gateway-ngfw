resource "aws_network_interface" "fw_mgmt_pri" {
  subnet_id         = aws_subnet.fw_mgmt_pri.id
  private_ips       = ["10.0.10.10"]
  source_dest_check = false

  tags = {
    Name = "fw_mgmt_interface_pri"
  }
}

resource "aws_network_interface" "fw_mgmt_sec" {
  subnet_id         = aws_subnet.fw_mgmt_sec.id
  private_ips       = ["10.0.20.10"]
  source_dest_check = false

  tags = {
    Name = "fw_mgmt_interface_sec"
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

resource "aws_network_interface" "fw_inside_sec" {
  subnet_id         = aws_subnet.fw_inside_sec.id
  private_ips       = ["10.0.21.10"]
  source_dest_check = false
  tags = {
    Name = "fw_inside_interface_sec"
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

resource "aws_network_interface" "fw_outside_sec" {
  subnet_id         = aws_subnet.fw_outside_sec.id
  private_ips       = ["10.0.22.10"]
  source_dest_check = false
  tags = {
    Name = "fw_outside_interface_sec"
  }
}

resource "aws_network_interface" "fw_heartbeat_pri" {
  subnet_id         = aws_subnet.fw_heartbeat_pri.id
  private_ips       = ["10.0.13.10"]
  source_dest_check = false
  tags = {
    Name = "fw_heartbeat_interface_pri"
  }
}

resource "aws_network_interface" "fw_heartbeat_sec" {
  subnet_id         = aws_subnet.fw_heartbeat_sec.id
  private_ips       = ["10.0.23.10"]
  source_dest_check = false
  tags = {
    Name = "fw_heartbeat_interface_sec"
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
  
  cpu_options {
    core_count = 2
    threads_per_core = 2

  }

  monitoring = false

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