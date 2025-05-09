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
 
module "myvm"{
    source = "./child_module"
    vm_count = 1
    environment = "dev"
    location = "East US"
    ci1 = "10.0.0.0"
    
}

