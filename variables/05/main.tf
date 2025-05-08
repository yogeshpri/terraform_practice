provider "azurerm" {
  features {}
}
 
resource "azurerm_resource_group" "rg" {
  name     = "apache-vm-rg2"
  location = var.location
}
 
resource "azurerm_virtual_network" "vnet" {
  name                = "apache-vnet2"
  address_space       = ["10.5.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
 
resource "azurerm_subnet" "subnet" {
  name                 = "apache-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.5.1.0/24"]
}
 
resource "azurerm_network_interface" "nic" {
  name                = "apache-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
 
resource "azurerm_public_ip" "pip" {
  name                = "apache-public-ip2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
 
resource "azurerm_network_security_group" "nsg" {
  name                = "apache-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
 
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
 
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
 
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "apache-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
 
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key)
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "apache-os-disk"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
 
  custom_data = filebase64("apache.sh")
}