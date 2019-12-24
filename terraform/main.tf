provider "azurerm" {
    version = "=1.38.0"
    subscription_id = ""
}

data "azurerm_image" "consul_image" {
  name                = "Azure-Consul-VM"
  resource_group_name = "packer"
}

resource "azurerm_public_ip" "consul_ip" {
  name                = "consul_ip"
  location            = "East US"
  allocation_method   = "Dynamic"
  resource_group_name = azurerm_resource_group.consul_resource_group.name
}

resource "azurerm_resource_group" "consul_resource_group" {
    name     = "consul"
    location = "East US"
}

resource "azurerm_virtual_network" "consul_network" {
    name                = "consul_network"
    resource_group_name = azurerm_resource_group.consul_resource_group.name
    location            = azurerm_resource_group.consul_resource_group.location
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.consul_resource_group.name
  virtual_network_name = azurerm_virtual_network.consul_network.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main" {
    name                = "consul-nic"
    location            = azurerm_resource_group.consul_resource_group.location
    resource_group_name  = azurerm_resource_group.consul_resource_group.name

    ip_configuration {
        name                          = "testconfiguration1"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.consul_ip.id
    }
}



resource "azurerm_virtual_machine" "main" {
  name                  = "consul-vm"
  location              = azurerm_resource_group.consul_resource_group.location
  resource_group_name   = azurerm_resource_group.consul_resource_group.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1S"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    id = data.azurerm_image.consul_image.id
  }
  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "consul"
    admin_username = "ubuntu"
    admin_password = ""
    custom_data = file("scripts/consul_azure.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}