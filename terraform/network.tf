resource "azurerm_virtual_network" "vnet" {
    location = azurerm_resource_group.rg.location
    name = "${random_pet.naming.id}-vnet"
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.vnet-ip-space]
}

resource "azurerm_subnet" "compute-subnet" {
    name = "${random_pet.naming.id}-compute-subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.subnet-ip-space]
}

resource "azurerm_subnet" "bastion-subnet" {
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.bastion-ip-space]
}

resource "azurerm_public_ip" "bastion-pip" {
    allocation_method = "Static"
    location = azurerm_resource_group.rg.location
    name = "${random_pet.naming.id}-bastion-pip"
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
    name = "${random_pet.naming.id}-bastion"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
    tunneling_enabled = true
    ip_connect_enabled = true
    shareable_link_enabled = true

    ip_configuration {
        name = "${random_pet.naming.id}-bastion-ipconfig"
        subnet_id = azurerm_subnet.bastion-subnet.id
        public_ip_address_id = azurerm_public_ip.bastion-pip.id
    }
}

