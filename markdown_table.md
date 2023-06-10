<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tgw_network"></a> [tgw\_network](#module\_tgw\_network) | ./module | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ami.fortigate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_watch_params"></a> [cloud\_watch\_params](#input\_cloud\_watch\_params) | values for cloudwatch logging | <pre>object({<br>    cloud_watch_on    = bool<br>    retention_in_days = number<br>  })</pre> | n/a | yes |
| <a name="input_firewall_defaults"></a> [firewall\_defaults](#input\_firewall\_defaults) | default subnet and interface values for firewall | <pre>object({<br>    subnets       = list(string)<br>    rt_tables     = list(string)<br>    instance_type = string<br>  })</pre> | n/a | yes |
| <a name="input_firewall_params"></a> [firewall\_params](#input\_firewall\_params) | options for fortigate firewall instance | <pre>object({<br>    firewall_name            = string<br>    outside_extra_public_ips = number<br>    inside_extra_private_ips = number<br>  })</pre> | n/a | yes |
| <a name="input_network_prefix"></a> [network\_prefix](#input\_network\_prefix) | prefix to prepend on all resource names within the network | `string` | n/a | yes |
| <a name="input_region_aws"></a> [region\_aws](#input\_region\_aws) | AWS Region | `string` | n/a | yes |
| <a name="input_spoke_vpc_params"></a> [spoke\_vpc\_params](#input\_spoke\_vpc\_params) | parameters for spoke VPCs | <pre>map(object({<br>    cidr_block = string<br>    subnets    = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_supernet_cidr"></a> [supernet\_cidr](#input\_supernet\_cidr) | cidr block for entire datacenter, must be /16 | `string` | n/a | yes |
| <a name="input_transit_gateway_defaults"></a> [transit\_gateway\_defaults](#input\_transit\_gateway\_defaults) | values for the transit gateway default option values | <pre>object({<br>    amazon_side_asn                 = number<br>    auto_accept_shared_attachments  = string<br>    default_route_table_association = string<br>    default_route_table_propagation = string<br>    multicast_support               = string<br>    dns_support                     = string<br>    vpn_ecmp_support                = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eips"></a> [eips](#output\_eips) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | n/a |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | n/a |
<!-- END_TF_DOCS -->