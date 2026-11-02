resource "local_file" "master_ssh_public_key" {
  content         = tls_private_key.master.public_key_openssh
  filename        = "${local.ssh_key_base_path}/master.pub"
  file_permission = "0600"
}

resource "local_file" "master_ssh_private_key" {
  content         = tls_private_key.master.private_key_openssh
  filename        = "${local.ssh_key_base_path}/master"
  file_permission = "0600"
}

resource "local_file" "worker_ssh_public_key" {
  for_each        = local.workers
  content         = tls_private_key.worker[each.key].public_key_openssh
  filename        = each.value.ssh_public_key_path
  file_permission = "0600"
}

resource "local_file" "worker_ssh_private_key" {
  for_each        = local.workers
  content         = tls_private_key.worker[each.key].private_key_openssh
  filename        = each.value.ssh_private_key_path
  file_permission = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("../files/ansible/inventory.ini", {
    domain               = local.cluster_domain
    workers              = keys(local.workers)
    ssh_private_key_path = local.ssh_key_base_path
  })
  filename = "../ansible/inventory/hosts.ini"
}

resource "local_file" "ansible_vars" {
  content = templatefile("../files/ansible/group_vars_all.yaml", {
    domain = "apps.${local.cluster_domain}"
  })
  filename = "../ansible/inventory/group_vars/all.yaml"
}

resource "local_file" "metallb_ipaddress" {
  content = templatefile("../files/kubernetes/metallb-system/ipaddress-pool.yaml", {
    ip = cidrhost(var.network_cidr, 100)
  })
  filename = "../kubernetes/metallb-system/ipaddress-pool.yaml"
}

resource "local_file" "forgejo_http_route" {
  content = templatefile("../files/kubernetes/scm/forgejo/http-route.yaml", {
    domain = local.cluster_domain
  })
  filename = "../kubernetes/scm/forgejo/http-route.yaml"
}
