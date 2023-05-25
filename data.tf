# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# AMI for FortiGate Instance
data "aws_ami" "fortigate" {
  owners = ["aws-marketplace"]
  #most_recent = true

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND*7.4.0*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnets" "spoke_vpc" {
  for_each = aws_vpc.spoke

  filter {
    name   = "vpc-id"
    values = [each.value.id]
  }
}