data "proxmox_virtual_environment_dns" "node_dns" {
  node_name = var.node_name
}
