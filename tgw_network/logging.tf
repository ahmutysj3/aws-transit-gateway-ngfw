resource "aws_s3_bucket" "flow_logs" {
  bucket        = "${var.network_prefix}-vpc-flow-logs"
  force_destroy = true

  tags = {
    Name        = "${var.network_prefix}-vpc-flow-logs"
    Environment = "dev"
  }
}

resource "aws_flow_log" "spoke" {
  for_each             = { for vpck, vpc in var.spoke_vpc_params : vpck => vpc }
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.spoke[each.key].id
}

resource "aws_flow_log" "firewall" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.firewall.id
}