provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kr" {
  name     = "kr-resources"
  location = "West Europe"
}

resource "azurerm_availability_set" "kr" {
  name                = "kr"
  location            = azurerm_resource_group.kr.location
  resource_group_name = azurerm_resource_group.kr.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kr.location
  resource_group_name = azurerm_resource_group.kr.name
}


resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kr.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}


resource "azurerm_public_ip" "ipaddressone1" {
  name                = "onePublicIp1"
  resource_group_name = azurerm_resource_group.kr.name
  location            = azurerm_resource_group.kr.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "ipaddressone2" {
  name                = "onePublicIp2"
  resource_group_name = azurerm_resource_group.kr.name
  location            = azurerm_resource_group.kr.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "interfaceone1" {
  name                = "interfaceOne1"
  location            = azurerm_resource_group.kr.location
  resource_group_name = azurerm_resource_group.kr.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ipaddressone1.id
  }
}

resource "azurerm_network_interface" "interfaceone2" {
  name                = "interfaceOne2"
  location            = azurerm_resource_group.kr.location
  resource_group_name = azurerm_resource_group.kr.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ipaddressone2.id
  }
}


resource "azurerm_linux_virtual_machine" "linux1" {
  name                = "Linux1-machine"
  resource_group_name = azurerm_resource_group.kr.name
  location            = azurerm_resource_group.kr.location
  size                = "Standard_F2"
  admin_username      = "ubuntu"
  admin_password      = "JKfklwr2398@!"
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.kr.id
  network_interface_ids = [
    azurerm_network_interface.interfaceone1.id
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "linux2" {
  name                = "Linux2-machine"
  resource_group_name = azurerm_resource_group.kr.name
  location            = azurerm_resource_group.kr.location
  size                = "Standard_F2"
  admin_username      = "ubuntu"
  admin_password      = "JKfklwr2398@!"
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.kr.id
  network_interface_ids = [
    azurerm_network_interface.interfaceone2.id
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
