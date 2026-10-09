resource "libvirt_pool" "default" {
  name = "terraform"
  type = "dir"

  target = {
    path = var.base_image_path
  }

  create = {
    build     = true
    start     = true
    autostart = true
  }
}

resource "libvirt_volume" "base" {
  name = "${var.cluster_name}-base.qcow2"
  pool = libvirt_pool.default.name

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = var.base_image_download_link
    }
  }
}
