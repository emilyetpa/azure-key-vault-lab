# 🔐 Azure Key Vault Lab — Bicep, Managed Identity & Azure RBAC

Infrastructure as Code (IaC) project that deploys an Azure Key Vault environment using **Bicep**, **Azure CLI**, **Managed Identity**, and **Azure RBAC**.

The project demonstrates how an Azure Virtual Machine can securely access secrets stored in Azure Key Vault without storing credentials directly in the VM or application code.

---

## 📌 Project Overview

This project focuses on implementing a secure Azure secrets-management architecture using Infrastructure as Code.

The environment includes:

* Azure Virtual Network
* VM subnet
* Ubuntu Virtual Machine
* System-assigned Managed Identity
* Azure Key Vault
* Azure RBAC
* Key Vault Secrets User role assignment
* Bicep modules
* Azure CLI deployment and validation

The main security principle demonstrated in this project is:

> **Use Managed Identity and Azure RBAC instead of storing credentials in application code or configuration files.**

---

## 🎯 Project Objectives

The objectives of this lab are to:

* Deploy Azure infrastructure using Bicep.
* Create a reusable modular Bicep architecture.
* Deploy an Azure Virtual Network and subnet.
* Deploy an Ubuntu Virtual Machine.
* Configure a system-assigned Managed Identity for the VM.
* Deploy an Azure Key Vault.
* Enable Azure RBAC authorization for Key Vault.
* Assign the **Key Vault Secrets User** role to the VM's Managed Identity.
* Practice Azure CLI deployment.
* Validate infrastructure using Bicep build and lint.
* Preview changes using Azure What-If.
* Manage the Infrastructure as Code project with Git and GitHub.
* Demonstrate the relationship between authentication and authorization.

---

# 🏗️ Architecture

```text
                         Azure
                           │
            ┌──────────────┴──────────────┐
            │            VNet              │
            │         10.30.0.0/16         │
            │                              │
            │    ┌────────────────────┐    │
            │    │     VM Subnet      │    │
            │    │    10.30.1.0/24    │    │
            │    │                    │    │
            │    │   ┌────────────┐   │    │
            │    │   │ Ubuntu VM  │   │    │
            │    │   │            │   │    │
            │    │   │ Managed    │   │    │
            │    │   │ Identity   │   │    │
            │    │   └─────┬──────┘   │    │
            │    └─────────┼──────────┘    │
            │              │               │
            └──────────────┼───────────────┘
                           │
                           │ Authentication
                           ▼
                  ┌─────────────────────┐
                  │ Microsoft Entra ID   │
                  └──────────┬──────────┘
                             │
                             │ Azure RBAC
                             │
                             ▼
                  ┌─────────────────────┐
                  │    Azure Key Vault  │
                  │                     │
                  │   AppSecret         │
                  │                     │
                  │ Key Vault Secrets   │
                  │       User          │
                  └─────────────────────┘
```

---

# 🔐 Security Model

The project separates **authentication** from **authorization**.

## Authentication

The VM uses a **system-assigned Managed Identity**.

```text
Ubuntu VM
    │
    │ Managed Identity
    ▼
Microsoft Entra ID
```

The VM does not need a username or password to authenticate to Azure services.

---

## Authorization

Azure RBAC determines what the Managed Identity can access.

```text
VM Managed Identity
        │
        │ Key Vault Secrets User
        ▼
Azure Key Vault
```

The role assignment is scoped specifically to the Key Vault.

This follows the principle of **least privilege**.

---

# 🧩 Azure Resources

| Resource          | Name                   | Purpose                                    |
| ----------------- | ---------------------- | ------------------------------------------ |
| Resource Group    | `RG-KEYVAULT-LAB`      | Contains the lab resources                 |
| Virtual Network   | `vnet-kv-dev`          | Provides private network connectivity      |
| VM Subnet         | `snet-vm`              | Hosts the VM network interface             |
| Ubuntu VM         | `vm-kv-dev`            | Workload that will access Key Vault        |
| Network Interface | `vm-kv-dev-nic`        | Provides network connectivity to the VM    |
| Azure Key Vault   | Custom unique name     | Stores secrets                             |
| Managed Identity  | System-assigned        | Provides passwordless Azure authentication |
| RBAC Role         | Key Vault Secrets User | Allows the VM identity to read secrets     |

---

# 📁 Project Structure

```text
azure-key-vault-lab/
│
├── main.bicep
├── main.parameters.json
├── README.md
├── .gitignore
│
├── modules/
│   ├── key-vault.bicep
│   ├── vnet.bicep
│   └── vm.bicep
│
├── architecture/
│   └── architecture.png
│
└── images/
```

---

# 🧱 Bicep Modules

## `main.bicep`

The main orchestration file.

It:

* Defines deployment parameters.
* Calls the VNet module.
* Calls the Key Vault module.
* Calls the VM module.
* Creates the Azure RBAC role assignment.

---

## `modules/vnet.bicep`

Creates:

* Virtual Network
* VM subnet

Configuration:

```text
VNet:     10.30.0.0/16
Subnet:   10.30.1.0/24
```

The module outputs the subnet resource ID so that the VM module can use it.

---

## `modules/key-vault.bicep`

Creates the Azure Key Vault.

The module:

* Configures the Key Vault.
* Associates it with the Microsoft Entra tenant.
* Enables Azure RBAC authorization.
* Configures the Key Vault SKU.
* Applies resource tags.

---

## `modules/vm.bicep`

Creates:

* Network Interface
* Ubuntu Virtual Machine
* System-assigned Managed Identity

The VM uses SSH public-key authentication.

Password-based SSH authentication is disabled.

---

# 🔗 Module Dependency Flow

```text
                    main.bicep
                        │
          ┌─────────────┼─────────────┐
          │             │             │
          ▼             ▼             ▼
       VNet          Key Vault        VM
       Module          Module        Module
          │                           │
          │ subnetId                  │
          └──────────────►────────────┘
                                      │
                                      │ principalId
                                      ▼
                              RBAC Role Assignment
                                      │
                                      ▼
                                  Key Vault
```

---

# ⚙️ Prerequisites

Before deploying the project, make sure you have:

* An active Azure subscription
* Azure CLI installed
* Bicep support through Azure CLI
* Visual Studio Code
* Git
* A GitHub account
* An SSH key pair

Check Azure CLI:

```powershell
az version
```

Check your Azure account:

```powershell
az account show
```

Check Bicep:

```powershell
az bicep version
```

---

# 🔑 SSH Key Requirement

Before deploying the Ubuntu VM, an **SSH key pair must be created first**.

Generate an SSH key pair using:

```powershell
ssh-keygen -t ed25519 -C "azure-key-vault-lab"
```

The **private key** is used to authenticate to the VM, while the **public key** is provided to Azure during deployment.

To display the public key:

```powershell
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"
```

> ⚠️ **Security:** Never upload or commit the private SSH key to GitHub.

---

# 📝 Parameter File

The deployment-specific values are stored in:

```text
main.parameters.json
```

Example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0",
  "parameters": {
    "location": {
      "value": "canadacentral"
    },
    "environment": {
      "value": "dev"
    },
    "vnetName": {
      "value": "vnet-kv-dev"
    },
    "vnetAddressPrefix": {
      "value": "10.30.0.0/16"
    },
    "subnetName": {
      "value": "snet-vm"
    },
    "subnetAddressPrefix": {
      "value": "10.30.1.0/24"
    },
    "vmName": {
      "value": "vm-kv-dev"
    },
    "adminUsername": {
      "value": "azureuser"
    },
    "sshPublicKey": {
      "value": "YOUR_SSH_PUBLIC_KEY"
    },
    "keyVaultName": {
      "value": "YOUR_UNIQUE_KEY_VAULT_NAME"
    },
    "tags": {
      "value": {
        "Environment": "dev",
        "Project": "Azure-Key-Vault-Lab"
      }
    }
  }
}
```

Replace:

```text
YOUR_SSH_PUBLIC_KEY
```

with your SSH public key.

Replace:

```text
YOUR_UNIQUE_KEY_VAULT_NAME
```

with a globally unique Key Vault name.

---

# 🔍 Validate the Bicep Code

Before deployment, build the Bicep template:

```powershell
az bicep build --file main.bicep
```

Run Bicep lint:

```powershell
az bicep lint --file main.bicep
```

You can also validate individual modules:

```powershell
az bicep build --file modules/vnet.bicep
az bicep build --file modules/key-vault.bicep
az bicep build --file modules/vm.bicep
```

---

# ☁️ Azure Subscription

Check the active subscription:

```powershell
az account show --output table
```

List available subscriptions:

```powershell
az account list --output table
```

Select the required subscription:

```powershell
az account set --subscription "YOUR-SUBSCRIPTION-NAME"
```

Verify:

```powershell
az account show --output table
```

---

# 📦 Create the Resource Group

Create the resource group:

```powershell
az group create `
  --name RG-KEYVAULT-LAB `
  --location canadacentral
```

Verify:

```powershell
az group show `
  --name RG-KEYVAULT-LAB `
  --output table
```

---

# 🔎 Azure What-If

Before creating the resources, preview the deployment:

```powershell
az deployment group what-if `
  --resource-group RG-KEYVAULT-LAB `
  --template-file main.bicep `
  --parameters '@main.parameters.json'
```

The What-If operation allows you to review the resources and changes that Azure plans to make before the actual deployment.

Expected resources include:

```text
Microsoft.Network/virtualNetworks
Microsoft.Network/networkInterfaces
Microsoft.Compute/virtualMachines
Microsoft.KeyVault/vaults
Microsoft.Authorization/roleAssignments
```

---

# 🚀 Deploy to Azure

After reviewing the What-If results, deploy the infrastructure:

```powershell
az deployment group create `
  --resource-group RG-KEYVAULT-LAB `
  --template-file main.bicep `
  --parameters '@main.parameters.json'
```

---

# ✅ Validate the Deployment

List resources in the resource group:

```powershell
az resource list `
  --resource-group RG-KEYVAULT-LAB `
  --output table
```

---

## Check the Virtual Network

```powershell
az network vnet show `
  --resource-group RG-KEYVAULT-LAB `
  --name vnet-kv-dev `
  --output table
```

---

## Check the VM

```powershell
az vm show `
  --resource-group RG-KEYVAULT-LAB `
  --name vm-kv-dev `
  --show-details `
  --output json
```

---

## Check the VM Managed Identity

```powershell
az vm show `
  --resource-group RG-KEYVAULT-LAB `
  --name vm-kv-dev `
  --query identity `
  --output json
```

The output should contain information about the system-assigned identity, including its principal ID.

---

## Check the Key Vault

```powershell
az keyvault show `
  --name YOUR_UNIQUE_KEY_VAULT_NAME `
  --resource-group RG-KEYVAULT-LAB `
  --output table
```

---

## Check the RBAC Assignment

```powershell
az role assignment list `
  --scope "/subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/RG-KEYVAULT-LAB/providers/Microsoft.KeyVault/vaults/YOUR_UNIQUE_KEY_VAULT_NAME" `
  --output table
```

The VM's Managed Identity should have the:

```text
Key Vault Secrets User
```

role.

---

# 🔐 Secret Management

The purpose of the project is to keep application secrets out of source code.

A secret can be created in Key Vault using Azure CLI:

```powershell
az keyvault secret set `
  --vault-name YOUR_UNIQUE_KEY_VAULT_NAME `
  --name AppSecret `
  --value "DemoSecretValue"
```

> ⚠️ For a real production environment, do not place real passwords, API keys, or other sensitive values directly in scripts or Git repositories.

---

# 🧪 Testing the Managed Identity

After deployment, the next validation objective is to demonstrate that the VM can authenticate to Azure using its Managed Identity.

The intended flow is:

```text
Ubuntu VM
    │
    │ Managed Identity
    ▼
Microsoft Entra ID
    │
    │ Authentication
    ▼
Azure RBAC
    │
    │ Key Vault Secrets User
    ▼
Azure Key Vault
    │
    ▼
AppSecret
```

The goal is to retrieve the secret without storing an Azure username, password, service principal secret, or other long-lived credential on the VM.

---

# 🛡️ Security Principles Demonstrated

This project demonstrates several Azure security principles.

### Least Privilege

The VM receives a specific Key Vault data-plane role rather than broad subscription or resource-group permissions.

### Managed Identity

The VM authenticates to Azure without requiring stored credentials.

### Azure RBAC

Access to Key Vault is controlled through role-based access control.

### SSH Key Authentication

Password-based SSH authentication is disabled.

### Infrastructure as Code

Infrastructure configuration is stored as Bicep code and managed through Git.

### Separation of Configuration and Infrastructure

Bicep templates define infrastructure while deployment-specific values are provided through a parameter file.

---

# 🔄 Git Workflow

The project is managed using Git.

Initialize the repository:

```powershell
git init
```

Set the main branch:

```powershell
git branch -M main
```

Check the repository:

```powershell
git status
```

Stage files:

```powershell
git add -A
```

Commit:

```powershell
git commit -m "Build Azure Key Vault infrastructure with Bicep"
```

Connect to GitHub:

```powershell
git remote add origin https://github.com/YOUR-USERNAME/azure-key-vault-lab.git
```

Push:

```powershell
git push -u origin main
```

---

# 🔄 Future Updates

After modifying the infrastructure:

```powershell
git status
```

Validate Bicep:

```powershell
az bicep build --file main.bicep
```

Run lint:

```powershell
az bicep lint --file main.bicep
```

Stage changes:

```powershell
git add -A
```

Commit:

```powershell
git commit -m "Update Key Vault infrastructure"
```

Push:

```powershell
git push
```

---

# 🗺️ Project Roadmap

### Phase 1 — Core Key Vault Architecture

* [x] Create Bicep project
* [x] Create VNet module
* [x] Create Key Vault module
* [x] Create VM module
* [x] Configure Managed Identity
* [x] Configure Azure RBAC
* [x] Create deployment parameter file
* [x] Validate Bicep
* [x] Run What-If
* [ ] Deploy to Azure
* [ ] Validate deployed resources
* [ ] Create test secret
* [ ] Test Managed Identity access

### Phase 2 — Security Hardening

Future improvements may include:

* Private Endpoint for Key Vault
* Private DNS Zone
* Network access restrictions
* Key Vault firewall configuration
* Azure Monitor integration
* Diagnostic settings
* Log Analytics
* Resource locks
* Additional RBAC review

### Phase 3 — Automation

Future improvements may include:

* GitHub Actions
* Automated Bicep validation
* Automated What-If
* Controlled Azure deployment
* CI/CD workflow

---

# 📚 Key Concepts Learned

This project provides hands-on practice with:

```text
Bicep
 │
 ├── Parameters
 ├── Modules
 ├── Outputs
 ├── Resource references
 ├── Existing resources
 ├── Dependencies
 └── RBAC resources
```

Azure:

```text
Azure Virtual Network
Azure VM
Azure Key Vault
Microsoft Entra ID
Managed Identity
Azure RBAC
```

Tools:

```text
VS Code
Azure CLI
Git
GitHub
PowerShell
```

---

# 🔗 Project Relationship

This project is part of a broader Azure infrastructure learning portfolio.

Previous projects:

```text
Azure NAT Gateway
        │
        ▼
Azure Bastion
        │
        ▼
Azure Private Endpoint
        │
        ▼
Azure Key Vault
        │
        ▼
Managed Identity + RBAC
```

The projects progressively demonstrate Azure networking, secure access, private connectivity, identity, authorization, and Infrastructure as Code.

---

# ⚠️ Security Notice

Do not commit sensitive information to this repository.

Never upload:

* SSH private keys
* Passwords
* API keys
* Client secrets
* Certificates containing private keys
* Access tokens
* Production credentials
* Real application secrets

The repository should contain infrastructure code and non-sensitive configuration only.

---

# 👨‍💻 Author

**Cedric Paolo Yetpa**

Azure | Cloud Infrastructure | Cybersecurity | Networking | Infrastructure as Code

---

## ⭐ Skills Demonstrated

`Azure` `Bicep` `Azure CLI` `Key Vault` `Managed Identity` `Azure RBAC` `Microsoft Entra ID` `Virtual Network` `Linux` `Git` `GitHub` `Infrastructure as Code` `Cloud Security`
