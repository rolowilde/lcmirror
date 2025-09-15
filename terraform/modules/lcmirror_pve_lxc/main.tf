terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">=0.83.2"
    }
  }
}

resource "proxmox_virtual_environment_container" "container" {
  depends_on = [
    proxmox_virtual_environment_download_file.debian_trixie_lxc_template,
    random_password.ct_root_password,
    tls_private_key.ct_private_key,
  ]

  node_name = var.node_name
  vm_id     = var.ct_id

  memory {
    dedicated = var.memory.dedicated
    swap      = var.memory.swap
  }

  cpu {
    cores        = var.cpu.cores
    architecture = var.cpu.architecture
    units        = var.cpu.units
  }

  initialization {
    hostname = var.hostname

    dynamic "ip_config" {
      for_each = var.ip_addresses
      content {
        dynamic "ipv4" {
          for_each = lookup(ip_config.value, "ipv4", null) != null ? [ip_config.value.ipv4] : []
          content {
            address = ipv4.value.address
            gateway = ipv4.value.gateway
          }
        }
        dynamic "ipv6" {
          for_each = lookup(ip_config.value, "ipv6", null) != null ? [ip_config.value.ipv6] : []
          content {
            address = ipv6.value.address
            gateway = ipv6.value.gateway
          }
        }
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ct_private_key.public_key_openssh)
      ]
      password = random_password.ct_root_password.result
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      name        = network_interface.value.name
      bridge      = network_interface.value.bridge
      enabled     = network_interface.value.enabled
      firewall    = network_interface.value.firewall
      mac_address = network_interface.value.mac_address
      mtu         = network_interface.value.mtu
      rate_limit  = network_interface.value.rate_limit
      vlan_id     = network_interface.value.vlan_id
    }
  }

  disk {
    size         = var.os_disk.size
    datastore_id = var.os_disk.datastore_id
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_trixie_lxc_template.id
    type             = "debian"
  }

  dynamic "mount_point" {
    for_each = var.mountpoints
    content {
      volume        = mount_point.value.volume
      path          = mount_point.value.path
      acl           = mount_point.value.acl
      mount_options = mount_point.value.mount_options
      quota         = mount_point.value.quota
      replicate     = mount_point.value.replicate
      read_only     = mount_point.value.read_only
      shared        = mount_point.value.shared
      backup        = mount_point.value.backup
      size          = mount_point.value.size
    }
  }

  started       = true
  start_on_boot = true
  unprivileged  = true

  features {
    nesting = true
  }
}

resource "proxmox_virtual_environment_download_file" "debian_trixie_lxc_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.node_name
  url          = "http://download.proxmox.com/images/system/debian-13-standard_13.1-1_amd64.tar.zst"
}

resource "random_password" "ct_root_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ct_private_key" {
  algorithm = "ED25519"
}
