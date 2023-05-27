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
    > security vpc where network virtual appliance will sit
- `protected` Virtual Private Cloud
- `management` Virtual Private Cloud
- `public` Virtual Private Cloud
- `dmz` Virtual Private Cloud

### Subnets

- /24 subnet created for each element listed in the subnets argument for `var.spoke_vpc_params`

## Resources Used

### Data Sources

- data.aws_ami
- data.aws_availability_zones
- data.aws_iam_policy_document
- data.aws_subnets

### Core Network

- aws_internet_gateway
- aws_internet_gateway_attachment
- aws_network_acl
- aws_network_acl_association
- aws_route
- aws_route_table
- aws_route_table_association
- aws_security_group
- aws_subnet
- aws_vpc

### Logging

- aws_cloudwatch_log_group
- aws_iam_policy
- aws_iam_policy_attachment
- aws_flow_log
- aws_s3_bucket

### Transit Gateway

- aws_ec2_transit_gateway
- aws_ec2_transit_gateway_route
- aws_ec2_transit_gateway_route_table
- aws_ec2_transit_gateway_route_table_association
- aws_ec2_transit_gateway_vpc_attachment
- aws_eip

### Firewall Instance

- aws_iam_instance_profile
- aws_iam_role
- aws_iam_role_policy
- aws_instance
- aws_network_interface
