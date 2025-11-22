#####################################
# Outputs
#####################################

# Add this output block
output "vm_ip_addresses" {
  description = "The list of IP addresses assigned to the VMs across all interfaces"
  value = local.node_networks
}
