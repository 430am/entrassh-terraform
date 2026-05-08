resource "azurerm_network_interface" "linux_nic" {
  location            = azurerm_resource_group.rg.location
  name                = "${random_pet.naming.id}-linux-nic"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${random_pet.naming.id}-linux-ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet["compute-subnet"].id
  }
}

resource "azurerm_network_interface" "windows_nic" {
  location            = azurerm_resource_group.rg.location
  name                = "${random_pet.naming.id}-windows-nic"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${random_pet.naming.id}-windows-ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet["compute-subnet"].id
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  location              = azurerm_resource_group.rg.location
  name                  = "${random_pet.naming.id}-linux-vm"
  network_interface_ids = [azurerm_network_interface.linux_nic.id]
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_sku
  tags                  = local.common_tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.vm_admin.result
  disable_password_authentication = false

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    name                 = "linux-osdisk-${random_pet.naming.id}"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.linux_vm_image.publisher
    offer     = var.linux_vm_image.offer
    sku       = var.linux_vm_image.sku
    version   = var.linux_vm_image.version
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  location              = azurerm_resource_group.rg.location
  name                  = "${random_pet.naming.id}-win-vm"
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_sku
  tags                  = local.common_tags

  admin_username = var.admin_username
  admin_password = random_password.vm_admin.result

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    name                 = "windows-osdisk-${random_pet.naming.id}"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.windows_vm_image.publisher
    offer     = var.windows_vm_image.offer
    sku       = var.windows_vm_image.sku
    version   = var.windows_vm_image.version
  }
}

resource "azurerm_virtual_machine_extension" "linux_login" {
  name                       = "AADSSHLoginForLinux"
  publisher                  = var.extension_publisher
  type                       = var.linux_login_extension
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_vm.id
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "windows_login" {
  name                       = "AADLoginForWindows"
  publisher                  = var.extension_publisher
  type                       = var.windows_login_extension
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.windows_vm.id
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}