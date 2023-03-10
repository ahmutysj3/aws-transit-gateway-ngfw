output "subnets" {
  value = { for k, v in aws_subnet.spokes :
    v.tags.Name =>
    {
      cidr : v.cidr_block,
      id : v.id,
      vpc : v.tags.vpc
    }
  }
}