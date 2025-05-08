locals {
  vm_size = "Standard_B1s"
  tags = {
    Name = "yogesh-vm1"
    Env  = "Dev"
  }
}
 
resource "azurerm_resource_group" "main" {
  name     = "yogesh-rg5"
  location = "canada central"
}
 
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet5"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
 
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet5"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_network_interface" "nic" {
  name                = "myNIC5"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
 
  tags = {
    Name = "My NIC"
  }
}
 
resource "azurerm_linux_virtual_machine" "myvm" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = local.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
    admin_ssh_key {
    username   = "yogesh"
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myOsDisk"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
 
  tags = local.tags
}