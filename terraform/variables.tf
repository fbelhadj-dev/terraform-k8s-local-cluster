# General 
variable "cluster_name" {
  type    = string
  default = "k8s"
}

# Network

variable "network_cidr" {
  description = "CIDR block for the cluster network"
  type        = string
  default     = "10.0.0.0/24"
}

# VM image

variable "base_image_download_link" {
  description = "Download link for the VM image"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "base_image_path" {
  description = "Base path for the VM image"
  type        = string
  default     = "/var/lib/libvirt/images/fedora-44-cloud.qcow2"
}

variable "libvirt_default_pool_dir" {
  description = "Path to the base directory for VM images"
  type        = string
  default     = "/var/lib/libvirt/images/terraform"
}

# SSH

variable "ssh_master_user" {
  description = "Username for the current VM connected to the master via SSH"
  type        = string
  default     = "master"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/k8s.pub"
}

# Master node

variable "master_mac" {
  type    = string
  default = "52:54:00:00:00:0a"
}

variable "master_root_password" {
  description = "Root password for the master node VM"
  type        = string
  sensitive   = true
}

# k8s

variable "k8s_version" {
  type    = string
  default = "v1.37"
}

variable "pod_network_cidr" {
  description = "CIDR for the Kubernetes pod network (Calico default)"
  type        = string
  default     = "10.244.0.0/16"
}
