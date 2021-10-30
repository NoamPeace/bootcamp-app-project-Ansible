
# Print public ip
# output "public_ip_address" {
#  value = var.public_ip_address
# }

# Print password for the VMs
output "random_password_generated" {
  description = "The random password generated:"
  value       = random_string.password.*.result
  sensitive   = false

}
