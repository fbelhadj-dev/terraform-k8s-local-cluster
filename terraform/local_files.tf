resource "local_file" "ansible_inventory" {
  content = templatefile("../files/ansible/inventory.ini", {
    domain               = local.cluster_domain
    workers              = keys(local.workers)
    ssh_private_key_path = var.ssh_private_key_path
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
