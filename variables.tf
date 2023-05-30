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
}