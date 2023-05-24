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

variable "supernet_index" {
  description = "this value will be used in second octet for network cidrs"
  type        = string
  default     = "251"
}

variable "firewall_vpc_cidr" {
  description = "cidr block for firewall vpc, must be at least /23"
  type        = string
  default     = "10.251.254.0/23"
}

variable "spoke_vpc_a_cidr" {
  description = "cidr block for firewall vpc, must be at least /23"
  type        = string
  default     = "10.251.0.0/23"
}

variable "spoke_vpc_b_cidr" {
  description = "cidr block for firewall vpc, must be at least /23"
  type        = string
  default     = "10.251.2.0/23"
}


variable "supernet_cidr" {
  description = "cidr block for entire datacenter, should be /16"
  type        = string
  default     = "10.200.0.0/16"
}