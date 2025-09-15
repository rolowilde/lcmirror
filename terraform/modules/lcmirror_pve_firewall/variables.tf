variable "node_name" {
  description = "Proxmox node where the VM or CT is located"
  type        = string
}

variable "ct_id" {
  description = "Proxmox LXC container ID"
  type        = number
  default     = null
}

variable "vm_id" {
  description = "Proxmox virtual machine ID"
  type        = number
  default     = null
}

variable "iface" {
  description = "VM/CT interface to apply the firewall rules to (must match 'net\\d+')"
  type        = string
}
