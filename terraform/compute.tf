resource "azurerm_network_interface" "linux-nic" {
    location = azurerm_resource_group.rg.location
    name = "${random_pet.naming.id}-linux-nic"
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "${random_pet.naming.id}-linux-ipconfig"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.main-subnet.id
    }
}

resource "azurerm_network_interface" "windows-nic" {
    location = azurerm_resource_group.rg.location
    name = "${random_pet.naming.id}-windows-nic"
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "${random_pet.naming.id}-windows-ipconfig"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.main-subnet.id
    }    
}

resource "azurerm_linux_virtual_machine" "linux-vm" {
    location = azurerm_resource_group.rg.location
    name = "${random_pet.naming.id}-linux-vm"
    network_interface_ids = [ azurerm_network_interface.linux-nic.id ]
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_D2als_v6"

    os_disk {
        caching = "ReadWrite"
        name = "linux-osdisk-${random_pet.naming.id}"
        storage_account_type = "Premium_LRS"
    }
    
    source_image_reference {
      publisher = var.linux-publisher
      offer = var.linux-offer
      sku = var.linux-sku
      version = "latest"
    }

    identity {
      type = "SystemAssigned"
    }

    admin_username = var.admin-username
    admin_password = random_string.password.result
}

resource "azurerm_windows_virtual_machine" "windows-vm" {
    location = azurerm_resource_group.rg.location
    name = "${random_pet.naming.id}-windows-vm"
    network_interface_ids = [ azurerm_network_interface.windows-nic.id ]
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_D2als_v6"
    os_disk {
        caching = "ReadWrite"
        name = "windows-osdisk-${random_pet.naming.id}"
        storage_account_type = "Premium_LRS"
    }
    
    source_image_reference {
      publisher = var.windows-publisher
      offer = var.windows-offer
      sku = var.windows-sku
      version = "latest"
    }

    identity {
      type = "SystemAssigned"
    }

    admin_username = var.admin-username
    admin_password = random_string.password.result
}

resource "azurerm_virtual_machine_extension" "windows-login" {
    name = "windows-login"
    publisher = var.extension-publisher
    type = var.windows-login-extension
    type_handler_version = "latest"
    virtual_machine_id = azurerm_windows_virtual_machine.windows-vm.id
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled = true
}

resource "azurerm_virtual_machine_extension" "linux-login" {
    name = "linux-login"
    publisher = var.extension-publisher
    type = var.linux-login-extension
    type_handler_version = "latest"
    virtual_machine_id = azurerm_linux_virtual_machine.linux-vm.id
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled = true
}