spoke_vpc_params = {
  public = {
    cidr_block = "10.200.0.0/20"
    subnets    = ["api", "sftp"]
    s3_logs = true
    cloudwatch = false
  }
  dmz = {
    cidr_block = "10.200.16.0/20"
    subnets    = ["app", "vpn", "nginx"]
    s3_logs = true
    cloudwatch = true
  }
  protected = {
    cidr_block = "10.200.32.0/20"
    subnets    = ["mysql_db", "vault", "consul"]
    s3_logs = true
    cloudwatch = true
  }
  management = {
    cidr_block = "10.200.48.0/20"
    subnets    = ["monitor", "logging", "admin"]
    s3_logs = true
    cloudwatch = false
  }
}
