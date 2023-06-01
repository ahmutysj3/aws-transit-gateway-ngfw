output "eips" {
  value = merge(
    { for eipk, eip in aws_eip.firewall : eipk => {
      name = eip.tags.Name,
      id   = eip.id,
      private_ip = eip.private_ip }
    },
    { for eipk, eip in aws_eip.outside_extra : eipk => {
      name       = eip.tags.Name,
      id         = eip.id,
      private_ip = eip.private_ip
      }
  })
}

output "transit_gateway" {
  value = {
    id          = aws_ec2_transit_gateway.main.id
    name        = aws_ec2_transit_gateway.main.tags.Name
    asn         = aws_ec2_transit_gateway.main.amazon_side_asn
    cidr_blocks = aws_ec2_transit_gateway.main.transit_gateway_cidr_blocks
  }
}

output "vpcs" {
  value = merge({
    firewall = {
      name       = aws_vpc.firewall.tags.Name
      id         = aws_vpc.firewall.id
      cidr_block = aws_vpc.firewall.cidr_block
      type       = aws_vpc.firewall.tags.type
    } },
    { for vpck, vpc in aws_vpc.spoke : vpck => {
      name       = vpc.tags.Name
      id         = vpc.id
      cidr_block = vpc.cidr_block
      type       = vpc.tags.type
      }
  })
}

output "subnets" {
  value = merge(
    { for subnetk, subnet in aws_subnet.spoke : subnetk => {
      name       = subnet.tags.Name
      id         = subnet.id
      az         = subnet.availability_zone
      type       = subnet.tags.type
      cidr_block = subnet.cidr_block
    } },
    { for subnetk, subnet in aws_subnet.firewall : subnetk => {
      name       = subnet.tags.Name
      id         = subnet.id
      az         = subnet.availability_zone
      type       = subnet.tags.type
      cidr_block = subnet.cidr_block

    } },
  )
}