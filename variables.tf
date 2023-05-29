variable "region_aws" {
  description = "AWS Region"
  type        = string
}

variable "firewall_defaults" {
  description = "default subnet and interface values for firewall"
  type = object({
    subnets       = list(string)
    rt_tables     = list(string)
    instance_type = string
  })

  default = {
    subnets       = ["outside", "inside", "heartbeat", "mgmt", "tgw"]
    rt_tables     = ["internal", "external", "tgw"]
    instance_type = "c6i.xlarge"
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