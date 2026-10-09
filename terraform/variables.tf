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
