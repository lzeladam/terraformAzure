# declare variables and defaults

variable "vm_name" {
  description = "VM name, up to 15 characters, numbers and letters, no special characters except hyphen -"
}

variable "admin_username"{
  description = "Admin user name for the virtual machine"
}

variable "location" {
  description = "Azure region"
}

variable "environment" {
  default = "dev"
}
variable "vm_size" {
  default = {
    "dev"  = "Standard_B2s"
    "prod" = "Standard_D2s_v3"
  }
}
# end vars

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "myTFModuleGroup"
  location = var.location
}

# Use the network module to create a vnet and subnet
module "network" {
  source              = "./modules/network"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = "10.0.0.0/16"
  subnet_names        = ["mySubnet"]
  subnet_prefixes     = ["10.0.1.0/24"]
}

# Use the compute module to create the VM
module "compute" {
  source         = "./modules/compute"
  location       = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_hostname    = var.vm_name
  vnet_subnet_id = element(module.network.vnet_subnets, 0)
  admin_username = var.admin_username
  remote_port    = "22"
  vm_os_simple   = "UbuntuServer"
  vm_size        = var.vm_size[var.environment]
  public_ip_dns  = ["zetadns"]
}