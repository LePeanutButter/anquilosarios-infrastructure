# Anquilosaurios Infrastructure

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![CI/CD Status](https://github.com/LePeanutButter/anquilosaurios-infrastructure/.github/workflows/main.yaml/badge.svg)](https://github.com/LePeanutButter/anquilosaurios-infrastructure/.github/workflows/main.yaml)
[![Terrascan Compliance](https://img.shields.io/badge/Security%20Scan-Terrascan%20Passed-green.svg)](link-to-terrascan-logs)

Terraform-driven Azure infrastructure for deploying a multi-VM, Docker-based environment with an Azure Load Balancer, Virtual Network, Container Registry, and automated container provisioning.

This repository follows the **Standard Readme** specification and provides a modular, production-aware infrastructure structure designed to be used on small-scale Azure setups (including usage within Azure Free Tier constraints where applicable).

---

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
  - [Infrastructure Overview](#infrastructure-overview)
  - [Security and CI/CD Workflow](#security-and-cicd-workflow)
  - [Modules](#modules)
- [Maintainers](#maintainers)
- [License](#license)

## Background

`anquilosaurios-infrastructure` was created to provide a clean, modular, and repeatable way to deploy containerized workloads across multiple Azure virtual machines while keeping costs as low as possible.

This repository focuses on VM-based container deployments as a cost-efficient and fully controllable alternative for small projects, prototypes, student work, game backends, and distributed microservices—without relying on any managed orchestration platforms.

This repository follows these guiding principles:

- **Terraform modules** for separation of concerns
- **Cloud-init automation** for provisioning Docker, Docker Compose, and workload containers
- **Load balancer–based routing** to distribute traffic across VMs
- **Minimal SKUs** to remain compatible with Azure Free Tier where possible
- **Standard-Readme compliance** to ensure maintainability and ease of onboarding

## Install

You will need:

- [Terraform](https://www.terraform.io/) **${{ env.TF_VERSION }}** (or newer)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **[Terrascan](https://github.com/accurics/terrascan)** (for local security scanning)
- **SSH Public Key Content** (to pass as a required variable)

Install Terraform dependencies:

```sh
terraform init
```

Login to Azure:

```sh
az login
```

---

## Usage

Initialize and provision the entire infrastructure:

```sh
terraform plan
terraform apply
```

To destroy when no longer needed:

```sh
terraform destroy
```

### Required Variables

To deploy the infrastructure, you must provide your SSH public key. Create a file named **`terraform.tfvars`** in the root directory and add the necessary variables:

```hcl
# The SSH public key content (e.g., 'ssh-rsa AAAA...') is mandatory
admin_public_key    = "<Your SSH Public Key Content>"

# Optional variables to override defaults (see variables.tf for full list)
vm_count            = 2
location            = "eastus"
resource_group_name = "anquilosaurios-rg"
```

### Security and CI/CD Workflow

Infrastructure deployment is governed by a GitHub Actions CI/CD pipeline, ensuring security and consistency:

1.  **CI Validation:** Runs `terraform fmt`, `validate`, and **Terrascan** security analysis on every commit.
2.  **Plan Generation:** Creates an immutable `tfplan.out` artifact.
3.  **Manual Approval (CD Gate):** The deployment is paused at the **'production' GitHub Environment** until a maintainer manually approves the execution.
4.  **Deployment:** Only the approved plan is executed via `terraform apply`.

### Infrastructure Overview

The deployed environment includes:

- **Resource Group** — Central management container
- **Virtual Network & Subnet** — Private networking
- **Network Security Group** — Rules for SSH, HTTP(S), backend ports
- **Azure Container Registry (ACR)** — Stores container images
- **Public Load Balancer** — Distributes traffic across VMs
- **Backend Pool + NAT Rules** — Each VM gets its own SSH port
- **Linux Virtual Machines** — Provisioned via cloud-init
- **Docker + Docker Compose automation** — Deploys services at startup

#### Architecture Diagrams

### Modules

This repository is structured into independent Terraform modules:

#### **resource_group/**

Creates the Azure Resource Group used by all other modules.

Inputs:

- `resource_group_name`
- `location`

#### **network/**

Creates:

- Virtual Network
- Subnet
- Network Security Group
- NSG ↔ Subnet association

Open ports:

- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 5000 (backend services)
- 8080 (Unity or additional services)

#### **acr/**

Defines an Azure Container Registry (Basic Tier) with admin access enabled for development convenience.

#### **loadbalancer/**

Creates:

- Public IP
- Azure Load Balancer
- Backend pool
- TCP health probe
- Load balancer rules
- NIC ↔ backend pool associations
- SSH NAT rules (5001 → 22, 5002 → 22, …)

#### **compute/**

For each VM:

- Public IP, NIC, and Linux virtual machine.
- Uses **Cloud-init** to install Docker and Docker Compose.
- **Deploys three containerized services** (Svelte Frontend, .NET Backend, Unity WebGL) defined in `docker-compose.tpl` and pulled from the ACR.

## Maintainers

- [Lanapequin](https://github.com/Lanapequin) – Laura Natalia Perilla Quintero
- [LePeanutButter](https://github.com/LePeanutButter) – Santiago Botero Garcia
- [shiro](https://github.com/JoseDavidCastillo) – Jose David Castillo Rodriguez

## License

**Apache-2.0 License** © Anquilosaurios Team

---

This **README** follows the Standard Readme specification.
