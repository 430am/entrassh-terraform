resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.rg.location
  name                = "${random_pet.naming.id}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_ip_space]
  tags                = local.common_tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.value.name
  address_prefixes     = [each.value.address_space]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_network_security_group" "compute" {
  location            = azurerm_resource_group.rg.location
  name                = "${random_pet.naming.id}-compute-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  # No inbound rules — VM access is via Azure Bastion only. Outbound
  # traffic is allowed by the default rules (required for the Entra ID
  # login extensions to reach login.microsoftonline.com).
}

resource "azurerm_subnet_network_security_group_association" "compute" {
  network_security_group_id = azurerm_network_security_group.compute.id
  subnet_id                 = azurerm_subnet.subnet["compute-subnet"].id
}

resource "azurerm_public_ip" "bastion_pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "${random_pet.naming.id}-bastion-pip"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  location            = azurerm_resource_group.rg.location
  name                = "${random_pet.naming.id}-bastion"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = local.common_tags

  ip_connect_enabled     = true
  shareable_link_enabled = true
  tunneling_enabled      = true

  ip_configuration {
    name                 = "${random_pet.naming.id}-bastion-ipconfig"
    subnet_id            = azurerm_subnet.subnet["bastion-subnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

