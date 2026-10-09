# General 
variable "cluster_name" {
  type    = string
  default = "k8s"
}

# Network

variable "network_cidr" {
  description = "CIDR block for the cluster network"
  type        = string
  default     = "192.168.100.0/24"
}

# VM image

variable "base_image_download_link" {
  description = "Download link for the VM image"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "base_image_path" {
  description = "Path to the base directory for VM images"
  type        = string
  default     = "/var/lib/libvirt/images/terraform"
}
