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
