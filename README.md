# AWS Transit Gateway VPC Network

AWS Network Environment using Transit Gateway

## Overview

This terraform plan builds a network in **AWS**.

Use of this module/s will require setting up **Terraform AWS Provider & AWS-CLI** (along w/credentials setup etc) before running terraform init

## Instructions

- define region, transit gateway options, firewall options and vpc names for network in the *terraform.tfvars* file
- define supernet and network prefix name in *main.tf*

## Network Structure

### Hub-Spoke Design utilizing Transit Gateway

- `firewall` Virtual Private Cloud
- `protected` Virtual Private Cloud
- `management` Virtual Private Cloud
- `public` Virtual Private Cloud
- `dmz` Virtual Private Cloud

### Subnets

- /24 subnet created for each element listed in the subnets argument for `var.spoke_vpc_params`

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
| <a name="input_firewall_defaults"></a> [firewall\_defaults](#input\_firewall\_defaults) | default subnet and interface values for firewall | <pre>object({<br>    subnets       = list(string)<br>    rt_tables     = list(string)<br>    instance_type = string<br>  })</pre> | n/a | yes |
| <a name="input_region_aws"></a> [region\_aws](#input\_region\_aws) | AWS Region | `string` | n/a | yes |
| <a name="input_transit_gateway_defaults"></a> [transit\_gateway\_defaults](#input\_transit\_gateway\_defaults) | values for the transit gateway default option values | <pre>object({<br>    amazon_side_asn                 = number<br>    auto_accept_shared_attachments  = string<br>    default_route_table_association = string<br>    default_route_table_propagation = string<br>    multicast_support               = string<br>    dns_support                     = string<br>    vpn_ecmp_support                = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eips"></a> [eips](#output\_eips) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | n/a |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | n/a |
<!-- END_TF_DOCS -->