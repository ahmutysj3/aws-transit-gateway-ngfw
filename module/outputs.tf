output "firewall" {
  value = {
    id                = aws_instance.fortigate.id
    name              = aws_instance.fortigate.tags.Name
    availability_zone = aws_instance.fortigate.availability_zone
    private_ip        = aws_instance.fortigate.private_ip
    primary_vnic      = aws_instance.fortigate.primary_network_interface_id
    port_map = { for k, v in aws_network_interface.firewall : k => { id = v.id, fw_port = "port${element([for k in v.attachment : k.device_index], 0)}" }
    }
  }
}

output "network_interfaces" {
  value = { for k, v in aws_network_interface.firewall : k => {
    id      = v.id,
    name    = v.tags.Name,
    subnet  = v.subnet_id,
    ip      = v.private_ip,
    fw_port = "port${element([for k in v.attachment : k.device_index], 0)}"
  } }
}

output "eips" {
  value = merge(
    { for eipk, eip in module.network.eips.firewall_outside : eipk => {
      name = eip.tags.Name,
      id   = eip.id,
      private_ip = eip.private_ip }
    },
    { for eipk, eip in module.network.eips.outside_extra : eipk => {
      name       = eip.tags.Name,
      id         = eip.id,
      private_ip = eip.private_ip
    }
  })
}

output "s3_logs" {
  value = merge(aws_flow_log.firewall, aws_flow_log.spoke)
}

output "s3_bucket" {
  value = aws_s3_bucket.flow_logs
}

output "transit_gateway" {
  value = aws_ec2_transit_gateway.main
}

output "transit_gateway_vpc_attachments" {
  value = merge(aws_ec2_transit_gateway_vpc_attachment.spoke, aws_ec2_transit_gateway_vpc_attachment.firewall)
}

output "transit_gateway_rt_tables" {
  value = aws_ec2_transit_gateway_route_table.main
}

output "vpcs" {
  value = {
    firewall = aws_vpc.firewall
    spoke    = aws_vpc.spoke
  }
}

output "internet_gateway" {
  value = aws_internet_gateway.main
}

output "network_acls" {
  value = aws_network_acl.main
}

output "network_sgs" {
  value = aws_security_group.firewall
}

output "subnets" {
  value = {
    firewall = aws_subnet.firewall
    spoke    = aws_subnet.spoke
  }
}

output "rt_tables" {
  value = {
    firewall = aws_route_table.firewall
    spoke    = aws_route_table.spoke
  }
}