locals {
  ssh_key_base_path = pathexpand(var.ssh_key_base_path)
  cluster_domain    = "${var.cluster_name}.lab.internal"
  master_ip         = cidrhost(var.network_cidr, 10)

  workers = {
    for i, mac in var.worker_macs :
    "worker-${i + 1}" => {
      mac                  = mac
      ssh_public_key_path  = "${local.ssh_key_base_path}/worker-${i + 1}.pub"
      ssh_private_key_path = "${local.ssh_key_base_path}/worker-${i + 1}"
    }
  }
}
