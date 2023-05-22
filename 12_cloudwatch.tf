resource "aws_cloudwatch_log_group" "flow_logs" {
  name         = "${var.network_prefix}_flow_log_grp"
  skip_destroy = false
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role" "flow_logs" {
  name               = "${var.network_prefix}_flow_log_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${var.network_prefix}_flow_log_iam_policy"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "cloud_watch_firewall_vpc" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.firewall_vpc.id
}

resource "aws_flow_log" "cloud_watch_spoke_a_vpc" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke_a_vpc.id
}

resource "aws_flow_log" "cloud_watch_spoke_b_vpc" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke_b_vpc.id
}