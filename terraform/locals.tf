locals {
  cluster_domain = "${var.cluster_name}.lab.internal"
  master_ip      = cidrhost(var.network_cidr, 10)

  workers = {
    for i, mac in var.worker_macs :
    "worker-${i + 1}" => {
      mac = var.worker_macs[i]
    }
  }
}
