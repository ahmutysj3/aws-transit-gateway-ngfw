/* output "firewall" {
  value = module.network.firewall
}

output "network_interfaces" {
  value = module.network.network_interfaces
}

output "eips" {
  value = module.network.eips
}


output "transit_gateway" {
  value = module.network.transit_gateway
}

output "transit_gateway_vpc_attachments" {
  value = module.network.transit_gateway_vpc_attachments
}

output "transit_gateway_rt_tables" {
  value = module.network.transit_gateway_rt_tables
}



output "vpcs" {
  value = module.network.vpcs
}

output "internet_gateway" {
  value = module.network.internet_gateway
}

*/

output "network_acls" {
  value = module.network.network_acls
}

output "network_sgs" {
  value = module.network.network_sgs
}

output "subnets" {
  value = module.network.subnets
}

output "rt_tables" {
  value = module.network.rt_tables
}