variable "admin_username" {
  description = "Local admin username created on each VM (used as fallback before Entra ID login is established)."
  type        = string
  default     = "localadmin"
}

variable "extension_publisher" {
  description = "Publisher of the Entra ID login VM extensions."
  type        = string
  default     = "Microsoft.Azure.ActiveDirectory"
}

variable "linux_login_extension" {
  description = "Type name of the Entra ID SSH login extension for Linux."
  type        = string
  default     = "AADSSHLoginForLinux"
}

variable "linux_vm_image" {
  description = "Marketplace image reference for the Linux VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

variable "location" {
  description = "Azure region in which to create resources."
  type        = string
  default     = "centralus"
}

variable "login_principal_id" {
  description = "Optional Entra ID object ID to grant 'Virtual Machine Administrator Login' on the resource group. Defaults to the identity Terraform is running as."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Subnets to create in the virtual network, keyed by logical name."
  type = map(object({
    name          = string
    address_space = string
  }))
  default = {
    compute-subnet = {
      name          = "compute-subnet"
      address_space = "10.0.0.0/24"
    }
    bastion-subnet = {
      name          = "AzureBastionSubnet"
      address_space = "10.0.1.0/26"
    }
  }
}

variable "tags" {
  description = "Base set of tags applied to all resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
    project    = "EntraID Authentication Demo"
    workload   = "virtual machines"
  }
}

variable "vm_sku" {
  description = "SKU for both virtual machines."
  type        = string
  default     = "Standard_D2als_v6"
}

variable "vnet_ip_space" {
  description = "Address space for the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "windows_login_extension" {
  description = "Type name of the Entra ID login extension for Windows."
  type        = string
  default     = "AADLoginForWindows"
}

variable "windows_vm_image" {
  description = "Marketplace image reference for the Windows VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}