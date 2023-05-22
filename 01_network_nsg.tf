resource "aws_security_group" "firewall" {
  depends_on  = [aws_vpc.firewall_vpc]
  name        = "Firewall Allow-All Security Group"
  description = "Allow all traffic to/from the Internet"
  vpc_id      = aws_vpc.firewall_vpc.id


  ingress {
    description = "Allow inbound traffic from the Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic to the Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}