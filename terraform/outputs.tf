output "resource_group_name" {
  description = "Name of the resource group containing all demo resources."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "Azure region the resources were deployed into."
  value       = azurerm_resource_group.rg.location
}

output "linux_vm_name" {
  description = "Name of the Linux VM. Connect via: az ssh vm --resource-group <rg> --vm-name <name>"
  value       = azurerm_linux_virtual_machine.linux_vm.name
}

output "windows_vm_name" {
  description = "Name of the Windows VM. Connect via Azure Bastion using your Entra ID account."
  value       = azurerm_windows_virtual_machine.windows_vm.name
}

output "bastion_name" {
  description = "Name of the Azure Bastion host used to reach both VMs."
  value       = azurerm_bastion_host.bastion.name
}

output "admin_username" {
  description = "Local admin username configured on both VMs (Entra ID login is the recommended path)."
  value       = var.admin_username
}
