# TXGrid – Infrastructure

TXGrid sets up a self-hosted 3 node lab on **Ubuntu + libvirt** using **Terraform**.  
It provisions cp0 (control plane), wk1, wk2 (workers) with:

- **Dual NICs per VM** – NAT for Internet, host-only network for cluster traffic
- **Static IPs** on host-only network (`192.168.50.0/24`)
- **Cloud-init automation** that:
  - installs the guest agent

---

## 🔧 Prerequisites

1. **Libvirt + QEMU on Ubuntu:**

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virt-manager bridge-utils
sudo systemctl enable --now libvirtd
sudo virsh net-start default
sudo virsh net-autostart default
```

2. **Enable ipv4 forwarding in the kernal.**
```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
```

4. **Terraform + tfswitch (recommended):**

```bash
sudo snap install tfswitch --classic    # Ubuntu

tfswitch   # will read .terraform-version and select correct version
terraform --version
```

**Add your user to the libvirt & kvm groups**
```bash
sudo usermod -aG libvirt,kvm ${USER}
```

4. Create apparmor profile for libvirt
```bash
sudo mkdir -p /etc/apparmor.d/abstractions/
sudo echo "/var/lib/libvirt/images/txgrid/** r," > /etc/apparmor.d/abstractions/libvirt-qemu
sudo apparmor_parser -r /etc/apparmor.d/abstractions/libvirt-qemu
sudo systemctl restart libvirtd
```

5. **SSH Keypair (if not already present):**

```bash
ssh-keygen -t ed25519 -C "txgrid"
```

Make sure the public key path is set in `variables.tf` (e.g. `~/.ssh/id_rsa.pub`).

---

## 🚀 Deploy the Lab

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Apply

```bash
terraform apply
```

Terraform will:

- Create host-only network (`virbr1`)
- Create thin-provisioned disks for cp0, wk1, wk2
- Generate cloud-init ISOs
- Boot all VMs

### 3. Verify Outputs

```bash
terraform output
```

You’ll see:

- **vm_ip_addresses** - map of nodes to network information

#### Note: There is known issue https://github.com/dmacvicar/terraform-provider-libvirt/issues/924 with the libvirt provider version 0.8.3 where the network information does not get refreshed. In that case rerun the apply command and it should populate with the information. I'm hoping migrating to version 0.9.0 will fix the problem.

---

## 🌐 Network Diagram

```
                   (Internet / Your Wi-Fi)
                             │
                        [Ubuntu Host]
                             │
                ┌────────────┴────────────┐
                │                         │
          virbr0 (NAT)               virbr1 (Host-only)
          192.168.122.0/24           192.168.50.0/24
          (libvirt "default")        (Terraform-created)
                │                         │
         DHCP to VMs for             Host bridge IP:
         outbound access             192.168.50.0 (gateway)
        ┌──────┼────────┐                 │
        │               │                 │
   [txgrid-cp0]    [txgrid-wk1]      [txgrid-wk2]
    ├─ ens3 → NAT    ├─ ens3 → NAT     ├─ ens3 → NAT
    └─ ens4 → 192.168.50.10/24         └─ ens4 → 192.168.50.12/24
                     └─ ens4 → 192.168.50.11/24

Key paths:
- VMs → Internet (pull images): via virbr0 NAT (DHCP on ens3)
```

**Legend**
- **virbr0** = libvirt’s built-in NAT network (`default`), gives VMs outbound Internet.
- **virbr1** = Terraform-defined host-only bridge (`hostnet`), static IPs for cluster traffic.
- **ens3** = NIC on virbr0 (DHCP).
- **ens4** = NIC on virbr1 (static: cp0 `.10`, wk1 `.11`, wk2 `.12`).
