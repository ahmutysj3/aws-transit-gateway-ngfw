# AWS Transit Gateway VPC Network

AWS Network Environment using Transit Gateway

## Overview

This terraform plan builds a network in **AWS**.

Use of this module/s will require setting up **Terraform AWS Provider & AWS-CLI** (along w/credentials setup etc) before running terraform init

## Instructions

- define region, network name, supernet, and vpc names for network in the *terraform.tfvars* file

## Network Structure

### Hub-Spoke Design utilizing Transit Gateway

- `firewall` Virtual Private Cloud
    > security vpc where network virtual appliance will sit
- `protected` Virtual Private Cloud
- `management` Virtual Private Cloud
- `public` Virtual Private Cloud
- `dmz` Virtual Private Cloud

## Resources Used

- data.aws_ami
- data.aws_availability_zones
- data.aws_iam_policy_document
- data.aws_subnets
- aws_cloudwatch_log_group
- aws_ec2_transit_gateway
- aws_ec2_transit_gateway_route
- aws_ec2_transit_gateway_route_table
- aws_ec2_transit_gateway_route_table_association
- aws_ec2_transit_gateway_vpc_attachment
- aws_eip
- aws_flow_log
- aws_iam_instance_profile
- aws_iam_policy
- aws_iam_policy_attachment
- aws_iam_role
- aws_iam_role_policy
- aws_instance
- aws_internet_gateway
- aws_internet_gateway_attachment
- aws_network_acl
- aws_network_acl_association
- aws_network_interface
- aws_route
- aws_route_table
- aws_route_table_association
- aws_s3_bucket
- aws_security_group
- aws_subnet
- aws_vpc_vpc

