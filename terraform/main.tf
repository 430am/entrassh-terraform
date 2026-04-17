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
    principal_id = "value"
    scope = "value"
    
}