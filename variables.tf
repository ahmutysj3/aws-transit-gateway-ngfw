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