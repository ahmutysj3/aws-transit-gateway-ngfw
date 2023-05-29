resource "aws_s3_bucket" "flow_logs" {
  bucket        = "${var.network_prefix}-vpc-flow-logs"
  force_destroy = true

  tags = {
    Name        = "${var.network_prefix}-vpc-flow-logs"
    Environment = "dev"
  }
}

resource "aws_flow_log" "spoke" {
  for_each             = { for vpck, vpc in var.spoke_vpc_params : vpck => vpc if vpc.s3_logs == true }
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

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  name         = "${var.network_prefix}_cloudwatch_log_grp"
  skip_destroy = false
}

resource "aws_iam_role" "flow_logs" {
  count = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  name               = "${var.network_prefix}_flow_log_iam_role"
  assume_role_policy = var.iam_policy_assume_role.json
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  name   = "${var.network_prefix}_flow_log_iam_policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = var.iam_policy_flow_logs.json
}

resource "aws_flow_log" "cloud_watch_firewall" {
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.firewall.id 
}

resource "aws_flow_log" "cloud_watch_spoke" {
  for_each        = { for vpck, vpc in var.spoke_vpc_params : vpck => vpc if var.cloud_watch_params.cloud_watch_on == true }
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke[each.key].id 
}