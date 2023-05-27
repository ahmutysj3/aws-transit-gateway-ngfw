module "network" {
  source                   = "./module"
  network_prefix           = "trace"
  supernet_cidr            = "10.200.0.0/16"
  region_aws               = var.region_aws
  availability_zone_list   = data.aws_availability_zones.available.names
  fortigate_ami            = data.aws_ami.fortigate
  spoke_vpc_params         = var.spoke_vpc_params
  firewall_params          = var.firewall_params
  transit_gateway_defaults = var.transit_gateway_defaults
}