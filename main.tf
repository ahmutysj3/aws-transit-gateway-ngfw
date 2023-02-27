data "aws_region" "current" {}

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
  for_each = {for k,v in keys(var.vpc_params) : v => k}
  ipam_pool_id = aws_vpc_ipam_pool.vpc[each.key].id
  cidr         = cidrsubnet(var.supernet,length(var.vpc_params),each.value)
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
} 
