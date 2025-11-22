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
