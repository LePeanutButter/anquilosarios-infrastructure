# Anquilosaurios Infrastructure

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

Terraform-driven Azure infrastructure for deploying a multi-VM, Docker-based environment with an Azure Load Balancer, Virtual Network, Container Registry, and automated container provisioning.

This repository follows the **Standard Readme** specification and provides a modular, production-aware infrastructure structure designed to be used on small-scale Azure setups (including usage within Azure Free Tier constraints where applicable).

---

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
  - [Infrastructure Overview](#infrastructure-overview)
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

- [Terraform](https://www.terraform.io/) ≥ 1.0
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- SSH key (public key)

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

- Public IP
- NIC
- Linux virtual machine
- cloud-init provisioning

Cloud-init installs:

- Docker
- Docker Compose
- Your workload from `compose.yaml`

## Maintainers

- [Lanapequin](https://github.com/Lanapequin) – Laura Natalia Perilla Quintero
- [LePeanutButter](https://github.com/LePeanutButter) – Santiago Botero Garcia
- [shiro](https://github.com/JoseDavidCastillo) – Jose David Castillo Rodriguez

## Contributing

This repository is not open for public contributions. For internal collaboration, please use Azure DevOps or GitHub Issues.

## License

**Apache-2.0 License** © Anquilosaurios Team

---

This **README** follows the Standard Readme specification.
