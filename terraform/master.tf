resource "libvirt_volume" "master" {
  name          = "${var.cluster_name}-master.qcow2"
  pool          = libvirt_pool.default.name
  capacity      = var.master_capacity_gb
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

  user_data = templatefile("../cloud-init/master/cloud-init.yaml", {
    hostname       = "master"
    domain         = local.cluster_domain
    root_password  = var.root_password
    ssh_user       = var.ssh_master_user
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    cilium_version = var.cilium_version

    # files
    profile           = filebase64("../files/cloud-init/profile.sh")
    containerd_config = filebase64("../files/cloud-init/containerd-config.toml")
    sysctl_k8s        = filebase64("../files/cloud-init/sysctl-k8s.conf")
    crictl            = filebase64("../files/cloud-init/crictl.yaml")
    k8s_repo = base64encode(templatefile("../files/cloud-init/k8s.repo", {
      k8s_version = var.k8s_version
    }))
    kubeadm_config = base64encode(templatefile("../files/cloud-init/kubeadm-config.yaml",
      {
        hostname    = "master"
        domain      = local.cluster_domain
        ip          = local.master_ip
        k8s_version = var.k8s_version
        pod_cidr    = var.pod_network_cidr
    }))
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

  memory      = var.master_memory_gb
  memory_unit = "GiB"
  vcpu        = var.master_vcpu
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
