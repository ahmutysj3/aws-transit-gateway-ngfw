resource "aws_s3_bucket" "flow_logs" {
  bucket = "${var.network_prefix}-vpc-flow-logs"

  tags = {
    Name        = "${var.network_prefix}-vpc-flow-logs"
    Environment = "dev"
  }
}

resource "aws_flow_log" "spoke_vpc_a" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.spoke_vpc_a.id
}