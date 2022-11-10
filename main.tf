terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "rg_name" {}
variable "vpc_name" {}
variable "az-security-group" {}
variable "env_prefix" {}
variable "avail_zone" {}
variable "vpc_cid_block" {}
variable "subnet_cidr_block" {}
variable "az_location" {}

resource "azurerm_resource_group" "example" {
  name     = var.rg_name
  location = var.avail_zone
}


resource "azurerm_network_security_group" "example" {
  name                = var.az-security-group
  location            = var.avail_zone
  resource_group_name = var.rg_name

  security_rule {
    name                   = "myhttp"
    priority               = 100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "tcp"
    destination_port_range = "8080"

  }

  tags = {
    Name : "${var.env_prefix}-${var.az-security-group}"
    environment = "${var.env_prefix}"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = var.vpc_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.vpc_cid_block
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "${var.rg_name}-subnet"
    address_prefix = var.subnet_cidr_block
  }

  tags = {
    environment = "${var.env_prefix}-${var.vpc_name}-vpc"
  }
}




