#####################################
# Locals
#####################################
locals {
  image_filename   = "ubuntu-${var.ubuntu_release}-server-cloudimg-${var.image_arch}.img"
  hostnet_cidr     = var.hostnet_subnet
  cloud_init_dir   = "${path.module}/cloud-init"
  base_url         = "https://cloud-images.ubuntu.com/releases/${var.ubuntu_series}/${var.ubuntu_release_build}"
  image_url        = "${local.base_url}/${local.image_filename}"
}

#####################################
# Host-only Network (virbr1)
#####################################
resource "libvirt_network" "hostnet" {
  name      = "hostnet"
  mode      = "nat"
  #autostart = true

  ips = [
    {
      address = "192.168.50.1"
      prefix  = 24
      dhcp = {
        enabled = true
        ranges = [
          {
            start = "192.168.50.2"
            end = "192.168.50.254"
          }
        ]
      }
    }
  ]
}

#####################################
# Per-node Disks based on the Base Image
#####################################
resource "libvirt_volume" "node_disks" {
  for_each = var.nodes

  name     = "${each.key}.qcow2"
  pool     = "default"
  format   = "qcow2"
  create   = {
    content = {
      url = local.image_url
    }
  }
}

#####################################
# Cloud-Init (user-data + network-config) per node
#####################################
resource "libvirt_cloudinit_disk" "node_ci" {
  for_each = var.nodes
  name     = "${each.key}-seed.iso"

  meta_data = templatefile("${local.cloud_init_dir}/meta.yaml.tmpl", {
    instance_id = each.key
    hostname    = each.key
  })

  user_data = templatefile("${local.cloud_init_dir}/node.yaml", {
    ssh_pubkey = file(var.ssh_pubkey)
    node_name  = each.key
    node_role  = each.value.role
    node_ip    = each.value.ip_address
  })

  network_config = templatefile("${local.cloud_init_dir}/net.yaml.tmpl", {
    ip_address = each.value.ip_address
    mac_lan     = lower(each.value.mac)          # br0 MAC
    mac_hostnet = lower(each.value.hostnet_mac)  # hostnet MAC    
  })
}

#####################################
# Stable Cloud-init ISO copied into default pool
# (avoids /tmp ISO + source.volume drift bugs)
#####################################
resource "libvirt_volume" "seed_iso" {
  for_each = var.nodes

  name   = "${each.key}-seed.iso"
  pool   = "default"
  format = "iso"

  create = {
    content = {
      url = libvirt_cloudinit_disk.node_ci[each.key].path
    }
  }

  depends_on = [libvirt_cloudinit_disk.node_ci]
}

#####################################
# Domains (VMs)
#####################################
resource "libvirt_domain" "nodes" {
  for_each = var.nodes

  name   = "txgrid-${each.key}"
  type   = "kvm"
  memory = each.value.memory
  unit   = "MiB"
  vcpu   = each.value.vcpu

  running = true
  autostart = true

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
  }

  devices = {
    disks = [
      {
        device = "disk"
        source = {
          pool = libvirt_volume.node_disks[each.key].pool
          volume = libvirt_volume.node_disks[each.key].name
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device   = "cdrom"
        readonly = true
        source = {
          pool = libvirt_volume.seed_iso[each.key].pool
          volume = libvirt_volume.seed_iso[each.key].name
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]
  
    interfaces = [
      {
        type   = "bridge"
        model  = "virtio"
        mac    = lower(each.value.mac)
        source = { bridge = "br0" }
      },
      {
        type   = "network"
        model  = "virtio"
        mac    = lower(each.value.hostnet_mac)
        source = { network = libvirt_network.hostnet.name }
      }
    ]

    channels = [
      {
        type = "unix"
        target_type = "virtio"
        target_name = "org.qemu.guest_agent.0"
      }
    ]

    #    serials = [
    #      {
    #        type = "pty"
    #        target_port = "0"
    #      }
    #    ]
    #
    #    consoles = [
    #      {
    #        type = "pty"
    #        target_type = "serial"
    #        target_port = "0"
    #      }
    #    ]

    graphics = {
      spice = {
        autoport = "yes"
        listen   = "127.0.0.1"
      }
    }
    video = {
      type = "virtio"
    }
  }
}

resource "time_sleep" "wait_for_nodes_600s" {
  depends_on = [libvirt_domain.nodes]
  create_duration = "600s"
}

locals {
  node_networks = [
    for n in libvirt_domain.nodes : n
  ]
}
