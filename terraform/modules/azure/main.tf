
// Ensures the Packer Consul VM Image exists and binds to a data source
data "azurerm_image" "consul" {
  name                = "Azure-Consul-VM"
  resource_group_name = "packer"
}

// Creates the Consul Azure Resource Group that owns all the Consul Resources
resource "azurerm_resource_group" "consul" {
    name     = "consul"
    location = "East US"
}

// Creates the Dynamic Public IP Address for the Consul Server
resource "azurerm_public_ip" "consul" {
  name                = "consul_ip"
  location            = "East US"
  allocation_method   = "Dynamic"
  resource_group_name = azurerm_resource_group.consul.name
}

resource "azurerm_virtual_network" "consul" {
    name                = "consul_virtual_network"
    resource_group_name = azurerm_resource_group.consul.name
    location            = azurerm_resource_group.consul.location
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "consul" {
  name                 = "consul_internal_subnet"
  resource_group_name  = azurerm_resource_group.consul.name
  virtual_network_name = azurerm_virtual_network.consul.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "consul" {
    name                = "consul_network_interface"
    location            = azurerm_resource_group.consul.location
    resource_group_name  = azurerm_resource_group.consul.name

    ip_configuration {
        name                          = "testconfiguration1"
        subnet_id                     = azurerm_subnet.consul.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.consul.id
    }
}

resource "azurerm_virtual_machine" "consul" {
  name                  = "consul_vm"
  location              = azurerm_resource_group.consul.location
  resource_group_name   = azurerm_resource_group.consul.name
  network_interface_ids = [azurerm_network_interface.consul.id]
  vm_size               = "Standard_B1S"

  storage_image_reference {
    id = data.azurerm_image.consul.id
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
    admin_password = var.azure_consul_password
    custom_data = file("${path.module}/scripts/consul_azure.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}