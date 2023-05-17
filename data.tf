# Data Sources - Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}