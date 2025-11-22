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
  mode      = "none"
  autostart = true

  addresses = [local.hostnet_cidr]

  dhcp {
    enabled = true
  }
}

#####################################
# Per-node Disks based on the Base Image
#####################################
resource "libvirt_volume" "node_disks" {
  for_each       = var.nodes

  name           = "${each.key}.qcow2"
  pool           = "default"
  source         = local.image_url
}

#####################################
# Cloud-Init (user-data + network-config) per node
#####################################
resource "libvirt_cloudinit_disk" "node_ci" {
  for_each = var.nodes
  name     = "${each.key}-seed.iso"
  pool     = "default"

  # Single generic node cloud-init template
  user_data = templatefile("${local.cloud_init_dir}/node.yaml", {
    ssh_pubkey = file(var.ssh_pubkey)
    node_name  = each.key
    node_role  = each.value.role
    node_ip    = each.value.ip_address
  })

  # Network-config template (still per-node data, same template)
  network_config = templatefile("${local.cloud_init_dir}/net.yaml.tmpl", {
    ip_address = each.value.ip_address
    iface_nat  = "ens3"
    iface_host = "ens4"
  })
}

#####################################
# Domains (VMs)
#####################################
resource "libvirt_domain" "nodes" {
  for_each = var.nodes

  name   = "txgrid-${each.key}"
  vcpu   = each.value.vcpu
  memory = each.value.memory
  qemu_agent = true

  # NIC 1 — NAT network (internet access)
  network_interface {
    bridge = "br0"
    mac    = each.value.mac
  }

  # NIC 2 — Host-only network
  network_interface {
    network_name = libvirt_network.hostnet.name
  }

  disk {
    volume_id = libvirt_volume.node_disks[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.node_ci[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

resource "time_sleep" "wait_for_nodes_900s" {
  depends_on = [libvirt_domain.nodes]
  create_duration = "900s"
}

locals {
  node_networks = [
    for n in libvirt_domain.nodes : {(n.name) : (n.network_interface)}
  ]
}
