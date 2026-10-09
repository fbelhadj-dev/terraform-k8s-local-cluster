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
