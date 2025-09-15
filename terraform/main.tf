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
      version = "0.83.2"
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

provider "proxmox" {
  endpoint  = "https://pve.in.example.com:8006/"
  username  = var.pve_username
  password  = var.pve_password
  insecure  = true
}

module "lcmirror_pve_lxc" {
  source    = "./modules/lcmirror_pve_lxc"
  node_name = "pve1"
  os_disk = {
    datastore_id = "local-zfs"
  }
  mountpoints = [
    {
      # bind mount, *requires* root@pam authentication
      volume = "/tank/mirror"
      path   = "/srv/mirror"
    }
  ]
}
