locals {
  cluster_domain = "${var.cluster_name}.lab.internal"
  master_ip      = cidrhost(var.network_cidr, 10)
}
