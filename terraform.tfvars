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

subnet_params = {
  vault = {
    cidr_mask = 25
    private = true
    vpc = "app"
  }

  mysql = {
    cidr_mask = 25
    private = true
    vpc = "db"
  }

  nginx = {
    cidr_mask = 26
    private = false
    vpc = "dmz"
  }
}