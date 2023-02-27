# set the region to deploy resources
region_aws = "us-east-1"

# define the supernet for the hub-spoke env
supernet = "10.1.0.0/16"

# a name to prepend to all source name tags
net_name = "trace"

# add one key for each VPC and value can be either ipam or manual for cidr allocation
vpc_params = {
  dmz = {
    cidr = "10.1.0.0/19"
  }
  app = {
    cidr = "10.1.32.0/19"
  }
  db = {
    cidr = "10.1.64.0/19"
  }
}

# add one key for each subnet and specify the key from vpc_params to assign to that vpc
subnet_params = {
  vault = {
    #cidr = "10.1.32.0/24"
    cidr_mask = 24
    public = true
    vpc = "app"
  }

  hosting = {
    #cidr = "10.1.33.0/24"
    cidr_mask = 24
    public = true
    vpc = "app"
  }

  mysql = {
    #cidr = "10.1.64.0/24"
    cidr_mask = 24
    public = true
    vpc = "db"
  }

  consul = {
    #cidr = "10.1.65.0/24"
    cidr_mask = 24
    public = true
    vpc = "db"
  }

  nginx = {
    #cidr = "10.1.0.0/24"
    cidr_mask = 24
    public = true
    vpc = "dmz"
  }

  openvpn = {
    #cidr = "10.1.1.0/24"
    cidr_mask = 24
    public = true
    vpc = "dmz"
  }
}