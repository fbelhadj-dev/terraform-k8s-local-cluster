output "master_interfaces" {
  description = "Master VM network interfaces and IP addresses"
  value       = data.libvirt_domain_interface_addresses.master.interfaces
}

output "worker_interfaces" {
  description = "Worker VM network interfaces and IP addresses"
  value = {
    for worker, interface in data.libvirt_domain_interface_addresses.worker :
    worker => interface.interfaces
  }
}

output "rendered_k8s_repo" {
  value = templatefile("../files/cloud-init/k8s.repo",
    {
      k8s_version = var.k8s_version
  })
}

output "rendered_kubeadm_config" {
  value = templatefile("../files/cloud-init/kubeadm-config.yaml",
    {
      hostname    = "master"
      domain      = local.cluster_domain
      ip          = local.master_ip
      k8s_version = var.k8s_version
      pod_cidr    = var.pod_network_cidr
  })
}
