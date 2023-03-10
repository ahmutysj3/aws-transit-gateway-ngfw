variable "region_aws" {
  description = "aws region"
  type        = string
}

variable "supernet" {
  description = "cidr for wan supernet"
  type        = string
}

variable "net_name" {
  description = "prepended to all resource name tags"
  type        = string
}

variable "vpc_params" {
  description = "inputs for vpc's"
  type = map(object({
    type = string
    cidr = string
  }))
}

variable "subnet_params" {
  description = "inputs for subnets"
  type = map(object({
    vpc       = string
    cidr_mask = number
    public    = bool
  }))
}

variable "tg_params" {
  description = "intputs for transit gateway"
  type = object({
    tg_name                         = string
    amazon_side_asn                 = number
    enable_dns_support              = bool
    enable_multicast_support        = bool
    enable_vpn_ecmp_support         = bool
    auto_accept_shared_attachments  = bool
    default_route_table_association = bool
    default_route_table_propagation = bool
  })
}