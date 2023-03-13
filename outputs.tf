output "subnets" {
  value = merge(
    { for k, v in aws_subnet.spoke :
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
        vpc : v.tags.vpc,
        purpose : v.tags.purpose
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