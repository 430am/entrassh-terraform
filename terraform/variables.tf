variable "location" {
  description = "The Azure region in which to create resources."
  type        = string
  default     = "centralus"
}

variable "linux-publisher" {
  description = "The publisher of the Azure VM image."
  type        = string
  default     = "Canonical"
}

variable "linux-offer" {
  description = "The offer of the Azure VM image."
  type        = string
  default     = "ubuntu-24_04-lts"
}

variable "linux-sku" {
  description = "The SKU of the Azure VM image."
  type        = string
  default     = "server"
}

variable "windows-publisher" {
  description = "The publisher of the Azure Windows VM image."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "windows-offer" {
  description = "The offer of the Azure Windows VM image."
  type        = string
  default     = "WindowsServer"
}

variable "windows-sku" {
  description = "The SKU of the Azure Windows VM image."
  type        = string
  default     = "2025-datacenter-g2"
}

variable "vnet-ip-space" {
  description = "The IP address space for the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet-ip-space" {
  description = "The IP address space for the subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "bastion-ip-space" {
  description = "The IP address space for the bastion host subnet."
  type        = string
  default     = "10.0.1.0/26"
}

variable "admin-username" {
  description = "The admin username for the virtual machines."
  type        = string
  default     = "ladmin"
}

variable "admin-password" {
  description = "The admin password for the virtual machines."
  type        = string
}

variable "extension-publisher" {
  description = "The publisher of the VM extension."
  type        = string
  default     = "Microsoft.Azure.ActiveDirectory"
}

variable "windows-login-extension" {
  description = "The type of the Windows VM extension."
  type        = string
  default     = "AADLoginForWindows"
}

variable "linux-login-extension" {
  description = "The type of the Linux VM extension."
  type        = string
  default     = "AADSSHLoginForLinux"
}