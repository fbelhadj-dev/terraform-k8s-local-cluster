resource "libvirt_volume" "master" {
  name          = "${var.cluster_name}-master.qcow2"
  pool          = libvirt_pool.default.name
  capacity      = 10
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

resource "libvirt_cloudinit_disk" "master" {
  name = "${var.cluster_name}-master.iso"

  meta_data = yamlencode({
    instance-id    = "master"
    local-hostname = "master"
  })

  user_data = templatefile("../cloud-init/master.yaml", {
    hostname             = "master"
    domain               = local.cluster_domain
    master_root_password = var.master_root_password
    ssh_user             = var.ssh_master_user
    ssh_public_key       = file(pathexpand(var.ssh_public_key_path))
  })
}

resource "libvirt_volume" "master_cloudinit" {
  name = "${var.cluster_name}-master.iso"
  pool = libvirt_pool.default.name

  target = {
    format = {
      type = "iso"
    }
  }

  create = {
    content = {
      url = libvirt_cloudinit_disk.master.path
    }
  }
}

resource "libvirt_domain" "master" {
  name = "${var.cluster_name}-master"
  type = "kvm"

  memory      = 2048
  memory_unit = "MiB"
  vcpu        = 2
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
            file = libvirt_volume.master.path
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
            file = libvirt_volume.master_cloudinit.path
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
        address = var.master_mac
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

data "libvirt_domain_interface_addresses" "master" {
  domain = libvirt_domain.master.name
  source = "lease"
}
