region_aws = "us-east-1"

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

