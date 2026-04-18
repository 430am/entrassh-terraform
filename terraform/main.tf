data "azurerm_client_config" "current" {}

resource "random_pet" "naming" {
    separator = ""
    length = 2
}

resource "random_string" "password" {
    length = 16
    special = true
    upper = true
    lower = true
    numeric = true
}

resource "azurerm_resource_group" "rg" {
    location = var.location
    name = "${random_pet.naming.id}-rg"
}

resource "azurerm_role_assignment" "windows-login" {
    principal_id = data.azurerm_client_config.current.object_id
    scope = azurerm_windows_virtual_machine.vm.id
    role_definition_name = "Virtual Machine Administrator Login"
    depends_on = [azurerm_windows_virtual_machine.vm]
}

resource "azurerm_role_assignment" "linux-login" {
    principal_id = data.azurerm_client_config.current.object_id
    scope = azurerm_linux_virtual_machine.vm.id
    role_definition_name = "Virtual Machine Administrator Login"
    depends_on = [azurerm_linux_virtual_machine.vm]
}