variable "node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "ct_id" {
  type        = number
  description = "Container ID"
  nullable = true
  default = null
}

variable "memory" {
  type = object({
    dedicated = number
    swap      = optional(number)
  })
  description = "Container memory config"
  default = {
    dedicated = 4096
  }
}

variable "cpu" {
  type = object({
    cores        = number
    units        = optional(number)
    architecture = optional(string)
  })
  description = "Container CPU config"
  default = {
    cores = 4
  }
}

variable "hostname" {
  type        = string
  description = "Container hostname"
  default = "lcmirror"
}

variable "ip_addresses" {
  type = list(object({
    ipv4 = optional(object({
      address = string
      gateway = optional(string)
    }))
    ipv6 = optional(object({
      address = string
      gateway = optional(string)
    }))
  }))
  description = "Container IP config list"
  default = [
    {
      ipv4 = {
        address = "dhcp"
      }
    }
  ]
}

variable "network_interfaces" {
  type = list(object({
    name        = string
    bridge      = string
    enabled     = optional(bool)
    firewall    = optional(bool)
    mac_address = optional(string)
    mtu         = optional(number)
    rate_limit  = optional(number)
    vlan_id     = optional(number)
  }))
  description = "Container network interface list"
  default = [
    {
      name   = "eth0"
      bridge = "vmbr0"
    }
  ]
}

variable "os_disk" {
  type = object({
    size         = optional(number, 8)
    datastore_id = string
  })
  description = "Container OS disk"
}

variable "mountpoints" {
  type = list(object({
    volume        = string
    path          = string
    acl           = optional(bool)
    backup        = optional(bool)
    mount_options = optional(list(string))
    quota         = optional(bool)
    read_only     = optional(bool)
    replicate     = optional(bool)
    shared        = optional(bool)
    size          = optional(string)
  }))
  description = "Container mountpoint list"
}
