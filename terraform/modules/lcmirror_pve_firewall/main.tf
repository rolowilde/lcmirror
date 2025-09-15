terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.83.2"
    }
  }
}

resource "proxmox_virtual_environment_firewall_rules" "rules" {
  node_name = var.node_name
  container_id = var.ct_id
  vm_id = var.vm_id
  rule {
    type = "in"
    action = "ACCEPT"
    macro = "Ping"
    iface = var.iface
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "FTP"
    iface = var.iface
  }
  rule {
    type = "in"
    action = "ACCEPT"
    macro = "Rsync"
    iface = var.iface
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "HTTP"
    iface = var.iface
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "HTTPS"
    iface = var.iface
  }
}

resource "proxmox_virtual_environment_firewall_options" "options" {
  node_name = var.node_name
  container_id = var.ct_id
  vm_id = var.vm_id
  enabled = true
  dhcp = true
  ndp = true
}
