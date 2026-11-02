terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
