terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
  encryption {
    key_provider "pbkdf2" "pbkdf2_key_provider" {
      passphrase = var.opentofu_passphrase
    }

    method "aes_gcm" "aes_gcm_method" {
      keys = key_provider.pbkdf2.pbkdf2_key_provider
    }

    state {
      method = method.aes_gcm.aes_gcm_method
    }

    plan {
      method = method.aes_gcm.aes_gcm_method
    }
  }
}

locals {
  mirror_root    = "/srv/mirror"
}

resource "proxmox_virtual_environment_container" "lcmirror" {
  vm_id     = 999
  node_name = "pve1"

  memory {
    dedicated = 16384
    swap      = 0
  }

  cpu {
    cores = 16
  }

  initialization {
    hostname = "lcmirror"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.lcmirror.public_key_openssh)]
      password = random_password.lcmirror.result
    }
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
  }

  disk {
    size         = 8
    datastore_id = "local-zfs"
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-13-standard_13.1-1_amd64.tar.zst"
    type             = "debian"
  }

  mount_point {
    # bind mount, *requires* root@pam authentication
    path   = local.mirror_root
    volume = "/tank/mirror"
  }

  started       = true
  start_on_boot = true
  unprivileged  = true

  features {
    nesting = true
  }
}

resource "proxmox_virtual_environment_firewall_rules" "lcmirror" {
  depends_on   = [proxmox_virtual_environment_container.lcmirror]
  node_name    = proxmox_virtual_environment_container.lcmirror.node_name
  container_id = proxmox_virtual_environment_container.lcmirror.vm_id
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "Ping"
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "FTP"
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    proto = "tcp"
    dport = "49152:65535"
    comment = "ftp pasv"
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "Rsync"
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "HTTP"
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "HTTPS"
  }
  rule {
    type   = "in"
    action = "ACCEPT"
    macro  = "SSH"
  }
}

resource "ansible_group" "mirrors" {
  name      = "mirrors"
}

resource "ansible_host" "lcmirror" {
  depends_on = [proxmox_virtual_environment_container.lcmirror]
  name       = "${proxmox_virtual_environment_container.lcmirror.initialization[0].hostname}.${data.proxmox_virtual_environment_dns.lcmirror.domain}"
  groups     = [ansible_group.mirrors.name]
  variables = {
    ansible_user           = "root"
    ansible_ssh_extra_args = "-o StrictHostKeyChecking=no"
    lcmirror_root      = local.mirror_root
  }
}

resource "proxmox_virtual_environment_firewall_options" "lcmirror" {
  node_name    = proxmox_virtual_environment_container.lcmirror.node_name
  container_id = proxmox_virtual_environment_container.lcmirror.vm_id
  enabled      = true
  dhcp         = true
}

resource "random_password" "lcmirror" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "lcmirror" {
  algorithm = "ED25519"
}

data "proxmox_virtual_environment_dns" "lcmirror" {
  depends_on = [proxmox_virtual_environment_container.lcmirror]
  node_name  = proxmox_virtual_environment_container.lcmirror.node_name
}

provider "proxmox" {
  endpoint = "https://pve1.example.com:8006/"
  username = var.pve_username
  password = var.pve_password
  insecure = true
}

variable "opentofu_passphrase" {
  type      = string
  sensitive = true
}

variable "pve_username" {
  type        = string
  description = "Proxmox VE API username"
  sensitive   = true
}

variable "pve_password" {
  type        = string
  description = "Proxmox VE API password"
  sensitive   = true
}

output "lcmirror_root_password" {
  value = random_password.lcmirror.result
  sensitive = true
}

output "lcmirror_ssh_private_key" {
  value = tls_private_key.lcmirror.private_key_openssh
  sensitive = true
}
