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

### TF Code for IPAM below

- IPAM resources and allocations do not play well with terraform build and destroy lifecycles so i'm leaving cidr manual for labbing
- i'm eventually going to turn this into a separate module that can be called with a bool set to true

/* data "aws_region" "current" {}

resource "aws_vpc_ipam" "trace" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_scope" "trace" {
  ipam_id     = aws_vpc_ipam.trace.id
  description = "main ipam scope"
}

resource "aws_vpc_ipam_pool" "public" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.trace.public_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool" "supernet" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.trace.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "supernet" {
  ipam_pool_id = aws_vpc_ipam_pool.supernet.id
  cidr         = var.supernet
}

resource "aws_vpc_ipam_pool" "vpc" {
  for_each = var.vpc_params
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.trace.private_default_scope_id
  locale              = data.aws_region.current.name
  source_ipam_pool_id = aws_vpc_ipam_pool.supernet.id
}


resource "aws_vpc_ipam_pool_cidr" "vpc" {
  for_each = var.vpc_params
  ipam_pool_id = aws_vpc_ipam_pool.vpc[each.key].id
  cidr         = each.value.cidr
}

resource "aws_vpc" "trace" {
  for_each = var.vpc_params
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.vpc[each.key].id
  ipv4_netmask_length = 22

  tags = {
    Name = "${var.net_name}_${each.key}_vpc"
  }

  depends_on = [
    aws_vpc_ipam_pool_cidr.vpc
  ]
}  */