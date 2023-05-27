# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "spoke_vpc" {
  for_each = aws_vpc.spoke

  filter {
    name   = "vpc-id"
    values = [each.value.id]
  }
}