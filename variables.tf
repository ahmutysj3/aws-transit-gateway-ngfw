variable "region_aws" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "Name of the SSH public key to be added to instance authorized_keys file"
  type        = string
  default     = "trace_linux_vm"
}

variable "network_prefix" {
  description = "prefix to prepend on all resource names within the network"
  type        = string
  default     = "trace"
}

variable "supernet_cidr" {
  description = "cidr block for entire datacenter, must be /16"
  type        = string
  default     = "10.200.0.0/16"
}

variable "spoke_vpc_params" {
  description = "parameters for spoke VPCs"
  type = map(object({
    cidr_block = string
    subnets    = list(string)
    s3_logs    = bool
    cloudwatch = bool
  }))

  default = {
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
}

variable "firewall_params" {
  description = "options for fortigate firewall instance"
  type = object({
    firewall_name            = string
    subnets = list(string)
    rt_tables = list(string)
    instance_type            = string
    outside_extra_public_ips = number
    inside_extra_private_ips = number
  })

  default = {
    firewall_name            = "fortigate_001"
    subnets = ["outside", "inside", "mgmt", "heartbeat", "tgw"]
    rt_tables =  ["internal", "external", "tgw"]
    instance_type            = "c6i.xlarge"
    outside_extra_public_ips = 3
    inside_extra_private_ips = 3
  }
}

variable "transit_gateway_defaults" {
  description = "values for the transit gateway default option values"
  type = object({
    amazon_side_asn                 = number
    auto_accept_shared_attachments  = string
    default_route_table_association = string
    default_route_table_propagation = string
    multicast_support               = string
    dns_support                     = string
    vpn_ecmp_support                = string
  })

  default = {
    amazon_side_asn                 = 64512
    auto_accept_shared_attachments  = "enable"
    default_route_table_association = "disable"
    default_route_table_propagation = "disable"
    multicast_support               = "disable"
    dns_support                     = "enable"
    vpn_ecmp_support                = "enable"
  }
}