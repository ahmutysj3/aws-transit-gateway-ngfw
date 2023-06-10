module "tgw_network" {
  source                   = "./module"
  network_prefix           = var.network_prefix
  supernet_cidr            = var.supernet_cidr
  region_aws               = var.region_aws
  iam_policy_assume_role   = data.aws_iam_policy_document.assume_role
  iam_policy_flow_logs     = data.aws_iam_policy_document.flow_logs
  availability_zone_list   = data.aws_availability_zones.available.names
  fortigate_ami            = data.aws_ami.fortigate
  firewall_defaults        = var.firewall_defaults
  transit_gateway_defaults = var.transit_gateway_defaults
  spoke_vpc_params         = var.spoke_vpc_params
  cloud_watch_params       = var.cloud_watch_params
  firewall_params          = var.firewall_params
}