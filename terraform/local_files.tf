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
    domain = local.cluster_domain
  })
  filename = "../ansible/inventory/group_vars/all.yaml"
}

