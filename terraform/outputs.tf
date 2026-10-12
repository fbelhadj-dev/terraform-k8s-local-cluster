output "master_interfaces" {
  description = "Master VM network interfaces and IP addresses"
  value       = data.libvirt_domain_interface_addresses.master.interfaces
}
