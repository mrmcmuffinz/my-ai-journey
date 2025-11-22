terraform {
  required_version = ">= 1.13.0, < 1.14.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.3"
    }
    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
  }
}
