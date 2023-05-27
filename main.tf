module "firewall" {
  source          = "./firewall"
  network_prefix  = var.network_prefix
  firewall_params = var.firewall_params
  ssh_key_name    = var.ssh_key_name
}