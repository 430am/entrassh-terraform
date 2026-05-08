# Entra ID Authentication for Azure VMs — Terraform

A small, opinionated Terraform sample that stands up a Linux VM and a
Windows VM, joins both to Microsoft Entra ID via the
`AADSSHLoginForLinux` / `AADLoginForWindows` extensions, and fronts
them with an Azure Bastion host. The goal is a reproducible pattern
for projects that need to retire SSH keys and local Windows passwords
in favour of Entra ID sign-in.

## What gets deployed

| Resource | Purpose |
| --- | --- |
| Resource group `<pet>-rg` | Container for everything below |
| Virtual network + two subnets | `compute-subnet` for the VMs, `AzureBastionSubnet` for Bastion |
| Network security group | Attached to the compute subnet; no inbound rules (Bastion-only access) |
| Public IP + Azure Bastion (Standard SKU) | Tunneling, IP-connect and shareable links enabled |
| Linux VM (Ubuntu 24.04 LTS) | System-assigned managed identity + `AADSSHLoginForLinux` extension |
| Windows VM (Windows Server 2025 DC) | System-assigned managed identity + `AADLoginForWindows` extension |
| Role assignment | `Virtual Machine Administrator Login` on the resource group, granted to the configured principal |

Naming uses a random `random_pet` prefix so multiple deploys can
co-exist in the same subscription.

## Repository layout

```text
terraform/
├── compute.tf        # NICs, both VMs, Entra login extensions
├── locals.tf         # Common tag merge
├── main.tf           # RG, random naming, random password, role assignment
├── network.tf        # VNet, subnets, NSG, Bastion + PIP
├── outputs.tf        # Resource group / VM / bastion names
├── providers.tf      # Required versions and azurerm features
├── variables.tf      # All inputs (defaults shown below)
└── environments/
    ├── creds.example.tfvars   # Template — copy to creds.tfvars locally
    └── creds.tfvars           # Gitignored; populate with your own creds
```

## Prerequisites

- Terraform >= 1.14
- Azure CLI (for `az login` and post-deploy `az ssh vm`)
- An Azure subscription where you can create resource groups, VMs and
  a Standard SKU Bastion host
- Permission in your Entra ID tenant to assign the
  `Virtual Machine Administrator Login` role at the resource-group
  scope

## Authentication

The provider block does **not** hard-code credentials. Use one of:

1. **Interactive (recommended for dev):**

   ```bash
   az login
   az account set --subscription <subscription-id>
   export ARM_SUBSCRIPTION_ID=<subscription-id>
   ```

2. **Service principal (CI):** set `ARM_CLIENT_ID`,
   `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` as
   environment variables. `terraform/environments/creds.example.tfvars`
   shows the expected names; copy it to `creds.tfvars` and source it
   before running Terraform:

   ```bash
   cp terraform/environments/creds.example.tfvars \
      terraform/environments/creds.tfvars
   # edit creds.tfvars
   set -a; source terraform/environments/creds.tfvars; set +a
   ```

   `*.tfvars` is gitignored — never commit a populated `creds.tfvars`.

3. **Workload Identity Federation** in CI is preferred over a
   long-lived client secret where supported.

> ⚠️ If you have ever pushed a populated `creds.tfvars` to a remote,
> rotate that client secret in Entra ID immediately.

## Usage

```bash
cd terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

After `apply`, the outputs include the resource group, both VM names
and the Bastion name.

### Connecting to the Linux VM

With Entra ID enabled you don't need an SSH key:

```bash
az ssh vm \
  --resource-group "$(terraform output -raw resource_group_name)" \
  --vm-name       "$(terraform output -raw linux_vm_name)"
```

### Connecting to the Windows VM

In the Azure portal, open the resource group, select the Windows VM,
choose **Connect → Bastion**, and pick **Microsoft Entra ID** as the
authentication type. The signed-in user must hold the
`Virtual Machine Administrator Login` (or `User Login`) role on the
VM or its scope — that role is assigned to the configured principal
by `azurerm_role_assignment.login_role`.

By default the role is granted to whichever identity Terraform
authenticated as. To grant it to a different user or group, set:

```hcl
login_principal_id = "<entra-object-id>"
```

## Inputs

| Name | Default | Notes |
| --- | --- | --- |
| `location` | `centralus` | Azure region |
| `vm_sku` | `Standard_D2als_v6` | Applied to both VMs |
| `vnet_ip_space` | `10.0.0.0/16` | |
| `subnets` | `compute-subnet`: `10.0.0.0/24`, `AzureBastionSubnet`: `10.0.1.0/26` | Map of `{name, address_space}` |
| `linux_vm_image` | Canonical Ubuntu 24.04 LTS | Object: publisher/offer/sku/version |
| `windows_vm_image` | Windows Server 2025 Datacenter (Gen2) | Object: publisher/offer/sku/version |
| `admin_username` | `localadmin` | Local fallback admin |
| `extension_publisher` | `Microsoft.Azure.ActiveDirectory` | |
| `linux_login_extension` | `AADSSHLoginForLinux` | |
| `windows_login_extension` | `AADLoginForWindows` | |
| `login_principal_id` | `null` | Overrides the default (current Terraform identity) |
| `tags` | `managed_by=terraform`, `project=EntraID Authentication Demo`, `workload=virtual machines` | Merged with `component` and `deployed_by` |

## Outputs

`resource_group_name`, `location`, `linux_vm_name`, `windows_vm_name`,
`bastion_name`, `admin_username`.

## Cleanup

```bash
terraform destroy
```

## Known limitations / future work

- **Password in state.** The VM admin password is generated by
  `random_password` and stored in Terraform state. Once the AzureRM
  provider exposes write-only support (`admin_password_wo` /
  `admin_password_wo_version`) for the VM resources, switch
  `random_password.vm_admin` to an `ephemeral` block to keep the
  secret out of state. The intended access path is Entra ID sign-in,
  so the local password should rarely be needed.
- **Local backend.** State is stored on disk. For shared use, add a
  remote backend (Azure Storage with state locking) in
  `providers.tf`.
- **No automated tests.** Add `*.tftest.hcl` files for plan-time
  assertions.
