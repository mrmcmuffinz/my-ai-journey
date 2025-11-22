#####################################
# VM Node Definitions
#####################################
variable "nodes" {
  description = <<EOT
Map of nodes to create. Keys are node names (cp0, wk1, wk2).
Values define vCPU, memory, disk size (GB), static IP, and role.
EOT

  type = map(object({
    memory     = number
    vcpu       = number
    disk_size  = number    # GB
    ip_address = string
    role       = string    # "control-plane" or "worker"
    mac        = string
  }))

  default = {
    cp0 = {
      memory     = 8192
      vcpu       = 4
      disk_size  = 60
      ip_address = "192.168.50.10"
      role       = "control-plane"
      mac        = "34:97:F6:AA:BB:C0"
    }
    wk1 = {
      memory     = 8192
      vcpu       = 4
      disk_size  = 60
      ip_address = "192.168.50.11"
      role       = "worker"
      mac        = "34:97:F6:AA:BB:C1"
    }
    wk2 = {
      memory     = 8192
      vcpu       = 4
      disk_size  = 60
      ip_address = "192.168.50.12"
      role       = "worker"
      mac        = "34:97:F6:AA:BB:C2"
    }
  }
}

#####################################
# Networking Variables
#####################################
variable "hostnet_subnet" {
  description = "CIDR for host-only network (used for kubeadm advertise-address)"
  type        = string
  default     = "192.168.50.0/24"
}

variable "hostnet_gateway" {
  description = "Gateway (bridge) address for host-only network (host side)"
  type        = string
  default     = "192.168.50.1"
}

#####################################
# Base Image Variables
#####################################
variable "ubuntu_release" {
  type        = string
  default     = "24.04"
}

variable "ubuntu_release_build" {
  type        = string
  default     = "release-20251031"
}

variable ubuntu_series {
  default = "noble"
}

variable "image_arch" {
  description = "Architecture for Ubuntu cloud image"
  type        = string
  default     = "amd64"
}


#####################################
# SSH & Cloud-Init
#####################################
variable "ssh_pubkey" {
  description = "Path to the SSH public key to inject via cloud-init"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
