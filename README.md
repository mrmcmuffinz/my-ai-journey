# My AI Journey

This repository documents my journey into **AI, MLOps,
infrastructure automation, and GPU-accelerated compute**.\
It includes Terraform-provisioned lab environments (TXGrid), machine
learning projects, and operational tooling like Ansible.

## Repository Structure

    .
    ├── infra/
    │   ├── terraform/      # Infrastructure as Code (TXGrid provisioning)
    │   └── ansible/        # Configuration management
    ├── labs/               # Jupyter notebooks, experiments
    ├── projects/           # End-to-end ML/AI projects
    ├── notes/              # Study notes & documentation
    └── README.md

## Goals

### 1. Build a full on-prem "AI lab" (TXGrid)

-   Terraform VM provisioning\
-   Cloud-init automation\
-   libvirt networking\
-   GPU workstation tuning\
-   Ansible configuration management

### 2. Learn and practice AI/ML fundamentals

-   Python + NumPy + Pandas\
-   Classical ML\
-   Deep learning

### 3. Move into MLOps, LLMs, and production concepts

-   Model serving\
-   Vector databases\
-   RAG pipelines\
-   Kubernetes + GPUs

### 4. Document everything thoroughly

## Infrastructure

Terraform lives in:

    infra/terraform/

Ansible lives in:

    infra/ansible/

## Roadmap

### Short-term

-   [ ] Add Ansible playbooks\
-   [ ] Add Terraform README\
-   [ ] Add GPU benchmarking notebook

### Medium-term

-   [ ] Deploy Kubernetes on TXGrid\
-   [ ] GPU operator\
-   [ ] LLM inference pipeline

### Long-term

-   [ ] Full AI platform on TXGrid\
-   [ ] Local RAG engine\
-   [ ] Blog writeups
