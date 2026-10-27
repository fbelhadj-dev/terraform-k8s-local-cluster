resource "libvirt_volume" "worker" {
  for_each = local.workers

  name          = "${var.cluster_name}-${each.key}.qcow2"
  pool          = libvirt_pool.default.name
  capacity      = var.worker_capacity_gb
  capacity_unit = "GiB"

  backing_store = {
    path = libvirt_volume.base.path
    format = {
      type = "qcow2"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "worker" {
  for_each = local.workers

  name = "${var.cluster_name}-${each.key}.iso"

  meta_data = yamlencode({
    instance-id    = each.key
    local-hostname = each.key
  })

  user_data = templatefile("../cloud-init/worker/cloud-init.yaml", {
    hostname       = each.key
    domain         = local.cluster_domain
    root_password  = var.root_password
    ssh_user       = "worker"
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))

    # files
    profile           = filebase64("../files/cloud-init/profile.sh")
    k8s_repo          = filebase64("../files/cloud-init/k8s.repo")
    containerd_config = filebase64("../files/cloud-init/containerd-config.toml")
    sysctl_k8s        = filebase64("../files/cloud-init/sysctl-k8s.conf")
    crictl            = filebase64("../files/cloud-init/crictl.yaml")
  })
}

resource "libvirt_volume" "worker_cloudinit" {
  for_each = local.workers

  name = "${var.cluster_name}-${each.key}.iso"
  pool = libvirt_pool.default.name

  target = {
    format = {
      type = "iso"
    }
  }

  create = {
    content = {
      url = libvirt_cloudinit_disk.worker[each.key].path
    }
  }
}

resource "libvirt_domain" "worker" {
  for_each = local.workers

  name = "${var.cluster_name}-${each.key}"
  type = "kvm"

  memory      = var.worker_memory_gb
  memory_unit = "GiB"
  vcpu        = var.worker_vcpu
  running     = true
  autostart   = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    boot_devices = [{ dev = "hd" }]
  }

  devices = {
    disks = [
      {
        device = "disk"
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        source = {
          file = {
            file = libvirt_volume.worker[each.key].path
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device    = "cdrom"
        read_only = true
        driver = {
          name = "qemu"
          type = "raw"
        }
        source = {
          file = {
            file = libvirt_volume.worker_cloudinit[each.key].path
          }
        }
        target = {
          dev = "hda"
          bus = "ide"
        }
      }
    ]

    interfaces = [{
      mac = {
        address = each.value.mac
      }
      source = {
        network = {
          network = libvirt_network.k8s.name
        }
      }
      model = {
        type = "virtio"
      }
    }]

    consoles = [{
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}

data "libvirt_domain_interface_addresses" "worker" {
  for_each = local.workers

  domain = libvirt_domain.worker[each.key].name
  source = "lease"
}
