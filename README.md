# AWS Transit Gateway VPC Network w/ IPAM

AWS Network Environment using Transit Gateway and managing IPs w/ IPAM scopes

## Overview

This terraform plan builds a network in **AWS**.

Use of this module/s will require setting up **Terraform AWS Provider & AWS-CLI** (along w/credentials setup etc) before running terraform init

## Instructions

- define region, network name, supernet, and vpc names for network in the *terraform.tfvars* file supernet variable

## Network Structure

### Hub-Spoke Design utilizing Transit Gateway

- `DMZ` Virtual Private Cloud
- `App` Virtual Private Cloud
- `DB` Virtual Private Cloud

## Resources Used

- aws_vpc
- aws_vpc_ipam
- aws_vpc_ipam_scope
- aws_vpc_ipam_pool
- aws_vpc_ipam_pool_cidr
