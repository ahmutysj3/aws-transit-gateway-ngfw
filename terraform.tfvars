# set the region to deploy resources
region_aws = "us-east-1"

# define the supernet for the hub-spoke env
supernet = "10.1.0.0/16"

# a name to prepend to all source name tags
net_name = "trace"

# add one key for each VPC and value can be either ipam or manual for cidr allocation
vpc_params = {
  sec = {
    type = "hub"
    cidr = "10.1.0.0/18"
  }
  dmz = {
    type = "spoke"
    cidr = "10.1.64.0/18"
  }
  app = {
    type = "spoke"
    cidr = "10.1.128.0/18"
  }
  db = {
    type = "spoke"
    cidr = "10.1.192.0/18"
  }
}

# add one key for each subnet and specify the key from vpc_params to assign to that vpc
# a default transit gateway subnet will be given its own subnet and that subnet cidr will follow conseq. w/ the last subnet in that vpc
subnet_params = {
  vault = {
    cidr_mask = 24
    public    = true
    vpc       = "app"
  }

  hosting = {
    cidr_mask = 24
    public    = true
    vpc       = "app"
  }

  mysql = {
    cidr_mask = 24
    public    = true
    vpc       = "db"
  }

  consul = {
    cidr_mask = 24
    public    = true
    vpc       = "db"
  }

  nginx = {
    cidr_mask = 24
    public    = true
    vpc       = "dmz"
  }

  openvpn = {
    cidr_mask = 24
    public    = true
    vpc       = "dmz"
  }
}

# inputs for settings parameters of the transit gateway
tg_params = {
  tg_name                         = "trace_main_tg"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = false
  default_route_table_association = false
  default_route_table_propagation = true
  enable_dns_support              = true
  enable_multicast_support        = true
  enable_vpn_ecmp_support         = false
}