terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
  backend "local" {
    path = "atelier2.tfstate"
  }
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "ca5c57dd-3aab-4628-a78c-978830d03bbd"
}

variable "vmname" {
  type = string
  default = "vm-terraform-atelier2"
}

data "azurerm_resource_group" "rg-name" {
  name = "rg-TDeOliveira2024_cours-terraform"
}

output "rg-location" {
  value = data.azurerm_resource_group.rg-name.location
}

output "rg-tags" {
  value = data.azurerm_resource_group.rg-name.tags
}

resource "azurerm_virtual_network" "network-atelier2" {
  name                = "network-atelier2"
  address_space       = ["10.10.0.0/16"]
  location            = data.azurerm_resource_group.rg-name.location
  resource_group_name = data.azurerm_resource_group.rg-name.name
  tags = {
    user = data.azurerm_resource_group.rg-name.tags["user"]
  }
}

resource "azurerm_subnet" "name" {
  name                 = "subnet-atelier2"
  resource_group_name  = data.azurerm_resource_group.rg-name.name
  virtual_network_name = azurerm_virtual_network.network-atelier2.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "name" {
  name                = "nic-atelier2"
  location            = data.azurerm_resource_group.rg-name.location
  resource_group_name = data.azurerm_resource_group.rg-name.name
  tags = {
    user = data.azurerm_resource_group.rg-name.tags.user
  }
  ip_configuration {
    name                          = "ipconfig-atelier2"
    subnet_id                     = azurerm_subnet.name.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-atelier2.id
  }
}

output "ip-nic-atelier2" {
  value = azurerm_network_interface.name.private_ip_address
}

resource "random_string" "bonus1" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "azurerm_linux_virtual_machine" "vm-atelier2" {
  name                            = var.vmname
  resource_group_name             = data.azurerm_resource_group.rg-name.name
  location                        = data.azurerm_resource_group.rg-name.location
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  network_interface_ids           = [azurerm_network_interface.name.id]
  disable_password_authentication = true
  tags = {
    user = data.azurerm_resource_group.rg-name.tags.user
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_ed25519.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
  source_image_reference {
    publisher = "Canonical"
    sku       = "server"
    offer     = "ubuntu-24_04-lts"
    version   = "latest"
  }
}

data "http" "ippubperso" {
  url = "https://ipinfo.io/ip"
}

resource "azurerm_network_security_group" "nsg-atelier2" {
  name                = "nsg-atelier2"
  location            = data.azurerm_resource_group.rg-name.location
  resource_group_name = data.azurerm_resource_group.rg-name.name
  tags = {
    user = data.azurerm_resource_group.rg-name.tags.user
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = data.http.ippubperso.response_body
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "name" {
  network_interface_id      = azurerm_network_interface.name.id
  network_security_group_id = azurerm_network_security_group.nsg-atelier2.id
}

resource "azurerm_public_ip" "pip-atelier2" {
  name                = "pip-atelier2"
  location            = data.azurerm_resource_group.rg-name.location
  resource_group_name = data.azurerm_resource_group.rg-name.name
  allocation_method   = "Static"
  tags = {
    user = data.azurerm_resource_group.rg-name.tags.user
  }
  domain_name_label = "${var.vmname}-${random_string.bonus1.result}"
}

output "ssh-command" {
  value = "ssh ${azurerm_linux_virtual_machine.vm-atelier2.admin_username}@${azurerm_public_ip.pip-atelier2.fqdn}"
}
