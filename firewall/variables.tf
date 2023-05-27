variable "firewall_params" {
  description = "options for fortigate firewall instance"
  type = object({
    firewall_name            = string
    subnets                  = list(string)
    rt_tables                = list(string)
    instance_type            = string
    outside_extra_public_ips = number
    inside_extra_private_ips = number
  })
}

variable "ssh_key_name" {
  description = "Name of the SSH public key to be added to instance authorized_keys file"
  type        = string
}

variable "network_prefix" {
  description = "prefix to prepend on all resource names within the network"
  type        = string
}