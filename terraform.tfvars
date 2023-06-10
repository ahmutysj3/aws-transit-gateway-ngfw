network_prefix = "trace"

supernet_cidr = "10.200.0.0/16"

region_aws = "us-east-1"

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

firewall_params = {
  firewall_name            = "fortigate_001"
  outside_extra_public_ips = 1
  inside_extra_private_ips = 2
}

firewall_defaults = {
  subnets       = ["outside", "inside", "heartbeat", "mgmt", "tgw"]
  rt_tables     = ["internal", "external", "tgw"]
  instance_type = "c6i.xlarge"
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

cloud_watch_params = {
  cloud_watch_on    = false
  retention_in_days = 30
}
