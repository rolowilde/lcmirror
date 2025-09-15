output "root_password" {
  description = "Password for root user"
  value     = random_password.ct_root_password.result
  sensitive = true
}

output "private_key" {
  description = "Private key for SSH access"
  value     = tls_private_key.ct_private_key.private_key_pem
  sensitive = true
}

output "public_key" {
  description = "Public key for SSH access"
  value = tls_private_key.ct_private_key.public_key_openssh
}

output "container" {
  value = proxmox_virtual_environment_container.ct_mirror
}
