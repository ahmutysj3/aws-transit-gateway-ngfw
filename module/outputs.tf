output "firewall" {
  value = {
    id                = aws_instance.fortigate.id
    name              = aws_instance.fortigate.tags.Name
    availability_zone = aws_instance.fortigate.availability_zone
    private_ip        = aws_instance.fortigate.private_ip
    primary_vnic      = aws_instance.fortigate.primary_network_interface_id
    port_num_map      = { for portk, port in aws_network_interface.firewall : "port${element([for portk in port.attachment : portk.device_index], 0) + 1}" => port.id }
    port_name_map     = { for portk, port in aws_network_interface.firewall : portk => port.id }
  }
}

output "network_interfaces" {
  value = { for portk, port in aws_network_interface.firewall : portk => {
    id      = port.id,
    name    = port.tags.Name,
    subnet  = port.subnet_id,
    ip      = port.private_ip,
    fw_port = "port${element([for attachk in port.attachment : attachk.device_index], 0) + 1}"
  } }
}

output "eips" {
  value = merge(
    { for eipk, eip in aws_eip.firewall : eipk => {
      name = eip.tags.Name,
      id   = eip.id,
      private_ip = eip.private_ip }
    },
    { for eipk, eip in aws_eip.outside_extra : eipk => {
      name       = eip.tags.Name,
      id         = eip.id,
      private_ip = eip.private_ip
      }
  })
}

output "transit_gateway" {
  value = {
    id          = aws_ec2_transit_gateway.main.id
    name        = aws_ec2_transit_gateway.main.tags.Name
    asn         = aws_ec2_transit_gateway.main.amazon_side_asn
    cidr_blocks = aws_ec2_transit_gateway.main.transit_gateway_cidr_blocks
  }
}

output "transit_gateway_vpc_attachments" {
  value = { for attachk, attach in merge(aws_ec2_transit_gateway_vpc_attachment.spoke, { firewall = aws_ec2_transit_gateway_vpc_attachment.firewall }) : attachk => {
    id   = attach.id,
    name = attach.tags.Name,
    tgw  = attach.transit_gateway_id,
    vpc  = attach.vpc_id
  } }
}

output "transit_gateway_rt_tables" {
  value = { for rt_tablek, rt_table in aws_ec2_transit_gateway_route_table.main : rt_tablek => {
    id   = rt_table.id,
    name = rt_table.tags.Name,
    tgw  = rt_table.transit_gateway_id,
  } }
}

output "vpcs" {
  value = merge({
    firewall = {
      name       = aws_vpc.firewall.tags.Name
      id         = aws_vpc.firewall.id
      cidr_block = aws_vpc.firewall.cidr_block
      type       = aws_vpc.firewall.tags.type
    } },
    { for vpck, vpc in aws_vpc.spoke : vpck => {
      name       = vpc.tags.Name
      id         = vpc.id
      cidr_block = vpc.cidr_block
      type       = vpc.tags.type
      }
  })
}

output "internet_gateway" {
  value = {
    name = aws_internet_gateway.main.tags.Name
    id   = aws_internet_gateway.main.id
  }
}

output "network_acls" {
  value = { for aclk, acl in aws_network_acl.main : aclk => {
    name = acl.tags.Name,
    id   = acl.id,
    vpc  = acl.vpc_id,
  subnet_ids = element([for subnet in acl.subnet_ids : subnet], 0) } }

}

output "network_sgs" {
  value = {
    name = aws_security_group.firewall.tags.Name
    id   = aws_security_group.firewall.id
  }
}

output "subnets" {
  value = merge(
    { for subnetk, subnet in aws_subnet.spoke : subnetk => {
      name       = subnet.tags.Name
      id         = subnet.id
      az         = subnet.availability_zone
      type       = subnet.tags.type
      cidr_block = subnet.cidr_block
    } },
    { for subnetk, subnet in aws_subnet.firewall : subnetk => {
      name       = subnet.tags.Name
      id         = subnet.id
      az         = subnet.availability_zone
      type       = subnet.tags.type
      cidr_block = subnet.cidr_block

    } },
  )
}

output "rt_tables" {
  value = merge(
    { for routek, route in aws_route_table.spoke : routek => {
      name = route.tags.Name
      id   = route.id
      vpc  = route.vpc_id
    } },
    { for routek, route in aws_route_table.firewall : routek => {
      name = route.tags.Name
      id   = route.id
      vpc  = route.vpc_id

  } })
}