module "network" {
  source                   = "./module"
  network_prefix           = "trace"
  supernet_cidr            = "10.200.0.0/16"
  region_aws               = var.region_aws
  iam_policy_assume_role   = data.aws_iam_policy_document.assume_role
  iam_policy_flow_logs     = data.aws_iam_policy_document.flow_logs
  availability_zone_list   = data.aws_availability_zones.available.names
  fortigate_ami            = data.aws_ami.fortigate
  firewall_defaults        = var.firewall_defaults
  transit_gateway_defaults = var.transit_gateway_defaults
  spoke_vpc_params = {
    public = {
      cidr_block = "10.200.0.0/20"
      subnets    = ["api", "sftp"]
    }
    dmz = {
      cidr_block = "10.200.16.0/20"
      subnets    = ["app", "vpn", "nginx"]
    }
    protected = {
      cidr_block = "10.200.32.0/20"
      subnets    = ["mysql_db", "vault", "consul"]
    }
    management = {
      cidr_block = "10.200.48.0/22"
      subnets    = ["monitor", "logging", "admin"]
    }
  }
  cloud_watch_params = {
    cloud_watch_on    = false
    retention_in_days = 30
  }

  firewall_params = {
    firewall_name            = "fortigate_001"
    outside_extra_public_ips = 1
    inside_extra_private_ips = 2
  }
}