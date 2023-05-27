spoke_vpc_params = {

  public = {
    cidr_block = "10.200.0.0/20"
    subnets    = ["api", "sftp"]
    s3_logs    = true
    cloudwatch = false
  }
  dmz = {
    cidr_block = "10.200.16.0/20"
    subnets    = ["app", "vpn", "nginx"]
    s3_logs    = true
    cloudwatch = true
  }
  protected = {
    cidr_block = "10.200.32.0/20"
    subnets    = ["mysql_db", "vault", "consul"]
    s3_logs    = true
    cloudwatch = true
  }
  management = {
    cidr_block = "10.200.48.0/20"
    subnets    = ["monitor", "logging", "admin"]
    s3_logs    = true
    cloudwatch = false
  }
}

firewall_params = {
  firewall_name            = "fortigate_001"
  subnets                  = ["outside", "inside", "mgmt", "heartbeat", "tgw"]
  rt_tables                = ["internal", "external", "tgw"]
  instance_type            = "c6i.xlarge"
  outside_extra_public_ips = 3
  inside_extra_private_ips = 3
}

transit_gateway_defaults = {
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  multicast_support               = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
}

region_aws = "us-east-1"