# Ansible Configuration (TXGrid)

This directory contains the **Ansible playbooks, roles, and
inventories** used to configure and manage the TXGrid environment after
the Terraform provisioning step.

Terraform is responsible for **creating** the VMs.\
Ansible is responsible for **configuring** them.

------------------------------------------------------------------------

## 📁 Folder Structure

    infra/ansible/
    ├── inventories/     # Host/group definitions
    ├── playbooks/       # Main playbooks (site.yml, bootstrap.yml, etc.)
    ├── roles/           # Reusable configuration roles
    └── group_vars/      # Variables for host groups

This layout follows Ansible best practices and keeps TXGrid
configuration modular and reusable.

------------------------------------------------------------------------

## 🚀 How to Use

1.  Ensure Terraform has finished provisioning TXGrid VMs:

    ``` bash
    cd ../terraform
    terraform apply
    ```

2.  Navigate to the Ansible directory:

    ``` bash
    cd infra/ansible
    ```

3.  Run a playbook (example: bootstrap all nodes):

    ``` bash
    ansible-playbook -i inventories/hosts playbooks/bootstrap.yml
    ```

------------------------------------------------------------------------

## 🔧 What Ansible Will Do

Typical tasks you will add here include:

-   System updates\
-   Package installation\
-   User setup\
-   SSH hardening\
-   Kubernetes dependencies\
-   GPU driver setup (if needed)\
-   Node labeling & configuration\
-   Custom TXGrid automation

As your lab grows, this folder will become the center of your machine
configuration pipeline.

------------------------------------------------------------------------

## 📌 Roadmap

-   [ ] Add base role for Ubuntu configuration\
-   [ ] Add bootstrap playbook for new TXGrid nodes\
-   [ ] Add GPU setup role\
-   [ ] Add Kubernetes cluster setup playbook
-

## Simple Network connectivity test

```shell
$ ansible all -i inventories/inventory.ini -m ansible.builtin.ping

[WARNING]: Host 'cp0' is using the discovered Python interpreter at '/usr/bin/python3.12', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
cp0 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
[WARNING]: Host 'wk1' is using the discovered Python interpreter at '/usr/bin/python3.12', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
wk1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
[WARNING]: Host 'wk2' is using the discovered Python interpreter at '/usr/bin/python3.12', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
wk2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}

$ ansible all -i inventories/inventory.ini -m raw -a "hostnamectl"
wk2 | CHANGED | rc=0 >>
 Static hostname: wk2
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 52fa678892aa4393893e5dc583628387
         Boot ID: cb07d31556bd4927b92148d11e7df25e
  Virtualization: kvm
Operating System: Ubuntu 24.04.3 LTS
          Kernel: Linux 6.8.0-87-generic
    Architecture: x86-64
 Hardware Vendor: QEMU
  Hardware Model: Standard PC _i440FX + PIIX, 1996_
Firmware Version: 1.16.3-debian-1.16.3-2
   Firmware Date: Tue 2014-04-01
    Firmware Age: 11y 7month 4w 1d
Shared connection to 192.168.50.12 closed.

wk1 | CHANGED | rc=0 >>
 Static hostname: wk1
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 478b53929467426cbfca44648c45c04c
         Boot ID: b0b123a5370e4b1ea1866d3e59a9d9c2
  Virtualization: kvm
Operating System: Ubuntu 24.04.3 LTS
          Kernel: Linux 6.8.0-87-generic
    Architecture: x86-64
 Hardware Vendor: QEMU
  Hardware Model: Standard PC _i440FX + PIIX, 1996_
Firmware Version: 1.16.3-debian-1.16.3-2
   Firmware Date: Tue 2014-04-01
    Firmware Age: 11y 7month 4w 1d
Shared connection to 192.168.50.11 closed.

cp0 | CHANGED | rc=0 >>
 Static hostname: cp0
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: d8fd42a2104b4316b4a8c76ba168a04f
         Boot ID: e15eb01787ad4bb9af70344a688f7f52
  Virtualization: kvm
Operating System: Ubuntu 24.04.3 LTS
          Kernel: Linux 6.8.0-87-generic
    Architecture: x86-64
 Hardware Vendor: QEMU
  Hardware Model: Standard PC _i440FX + PIIX, 1996_
Firmware Version: 1.16.3-debian-1.16.3-2
   Firmware Date: Tue 2014-04-01
    Firmware Age: 11y 7month 4w 1d
Shared connection to 192.168.50.10 closed.
```
