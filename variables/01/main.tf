resource "azurerm_resource_group" "example" {
  name  = "myrg${var.name}"
  location = "central india"
}
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.27.0"
    }
  }
}
 
provider "azurerm" {
  # Configuration options
features{}
}

output "name"{
  value = azurerm_resource_group.example.name
}