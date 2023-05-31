output "firewall" {
  value = module.tgw_network.firewall
}

output "network_interfaces" {
  value = module.tgw_network.network_interfaces
}

output "eips" {
  value = module.tgw_network.eips
}

output "transit_gateway" {
  value = module.tgw_network.transit_gateway
}

output "transit_gateway_vpc_attachments" {
  value = module.tgw_network.transit_gateway_vpc_attachments
}

output "transit_gateway_rt_tables" {
  value = module.tgw_network.transit_gateway_rt_tables
}

output "vpcs" {
  value = module.tgw_network.vpcs
}

output "internet_gateway" {
  value = module.tgw_network.internet_gateway
}

output "network_acls" {
  value = module.tgw_network.network_acls
}

output "network_sgs" {
  value = module.tgw_network.network_sgs
}

output "subnets" {
  value = module.tgw_network.subnets
}

output "rt_tables" {
  value = module.tgw_network.rt_tables
}