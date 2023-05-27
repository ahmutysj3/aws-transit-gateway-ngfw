module "tgw_network" {
  source                   = "./module"
  availability_zone_list = data.aws_availability_zones.available.names
  fortigate_ami = data.aws_ami.fortigate
  region_aws               = var.region_aws
  ssh_key_name             = var.ssh_key_name
  network_prefix           = var.network_prefix
  supernet_cidr            = var.supernet_cidr
  spoke_vpc_params         = var.spoke_vpc_params
  firewall_params          = var.firewall_params
  transit_gateway_defaults = var.transit_gateway_defaults
}