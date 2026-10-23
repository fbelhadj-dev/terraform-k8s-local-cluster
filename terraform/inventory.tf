resource "local_file" "ansible_inventory" {
  content = templatefile("../files/ansible/inventory.ini", {
    domain               = local.cluster_domain
    workers              = keys(local.workers)
    ssh_private_key_path = var.ssh_private_key_path
  })
  filename = "../ansible/inventory.ini"
}

