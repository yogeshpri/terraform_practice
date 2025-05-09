terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
 
}
 
provider "azurerm" {
  features {}
}
 
resource "azurerm_resource_group" "example" {
  name     = "yogesh-demo${terraform.workspace}"
  location = var.location
}
 
resource "azurerm_virtual_network" "example" {
  name                = "yogesh-network"
  address_space       = ["${var.ci1}/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
 
resource "azurerm_subnet" "example" {
  name                 = "yogesh-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["${var.ci1}/24"]
}
 
resource "azurerm_public_ip" "public_ip" {
  name                = "yogesh-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method = "Static"
}
 
resource "azurerm_network_interface" "example" {
  name                = "yogesh-nic${terraform.workspace}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
 
  ip_configuration {
    name                          = "internal${terraform.workspace}"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
 
resource "azurerm_linux_virtual_machine" "example" {
    count = var.vm_count
  name                = "yogesh-machine${count.index}${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "User11"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
 
  admin_ssh_key {
    username   = "User11"
    public_key = file("/home/user11/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
 
  tags = {
    Name = "dev"
  }
}