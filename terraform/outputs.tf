output "master_interfaces" {
  description = "Master VM network interfaces and IP addresses"
  value       = data.libvirt_domain_interface_addresses.master.interfaces
}

output "rendered_k8s_repo" {
  value = templatefile("../cloud-init/master/files/k8s.repo",
    {
      hostname    = "master"
      domain      = local.cluster_domain
      ip          = local.master_ip
      k8s_version = var.k8s_version
      pod_cidr    = var.pod_network_cidr
  })
}
