resource "libvirt_network" "k8s" {
  name = var.cluster_name

  forward = {
    mode = "nat"
  }

  bridge = {
    name = var.cluster_name
  }

  domain = {
    name       = local.cluster_domain
    local_only = "yes"
  }

  ips = [
    {
      address = cidrhost(var.network_cidr, 1)
      netmask = cidrnetmask(var.network_cidr)

      dhcp = {
        ranges = [{
          start = cidrhost(var.network_cidr, 10)
          end   = cidrhost(var.network_cidr, 20)
        }]

        hosts = [
          {
            mac = var.master_mac
            ip  = local.master_ip
          }
        ]
      }
    }
  ]

  dns = {
    enable = "yes"
  }
}
