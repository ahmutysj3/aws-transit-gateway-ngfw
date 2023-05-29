output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.flow_logs[0]
}
  
output "cloudwatch_logs" {
  value = merge(aws_flow_log.cloud_watch_firewall, aws_flow_log.cloud_watch_spoke)
}

output "firewall" {
  value = aws_instance.fortigate
}

output "network_interfaces" {
  value = aws_network_interface.firewall
}

output "eips" {
  value = merge(aws_eip.firewall,aws_eip.outside_extra)
}

output "s3_logs" {
  value = merge(aws_flow_log.firewall,aws_flow_log.spoke)
}

output "s3_bucket" {
  value = aws_s3_bucket.flow_logs
}

output "transit_gateway" {
  value = aws_ec2_transit_gateway.main
}

output "transit_gateway_vpc_attachments" {
  value = merge(aws_ec2_transit_gateway_vpc_attachment.spoke,aws_ec2_transit_gateway_vpc_attachment.firewall)
}

output "transit_gateway_rt_tables"  {
  value = aws_ec2_transit_gateway_route_table.main
}

output "vpcs" {
  value = {
    firewall = aws_vpc.firewall.id
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
  value = aws_security_group.main
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