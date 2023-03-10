output "subnets" {
  value = merge(
    { for k, v in aws_subnet.spokes :
      v.tags.Name => {
        cidr : v.cidr_block,
        id : v.id,
        vpc : v.tags.vpc
      }
    },
    { for k, v in aws_subnet.hub :
      v.tags.Name => {
        cidr : v.cidr_block,
        id : v.id,
        vpc : v.tags.vpc
      }
    }
  )
}

output "vpcs" {
  value = { for k, v in aws_vpc.main :
    v.tags.Name => {
      id : v.id,
      cidr : v.cidr_block,
      sec_grp : v.tags.vpc
      type : v.tags.type
    }
  }
}