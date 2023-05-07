provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "test-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "test" {
  name                = "test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name           = "test-subnet"
  address_prefixes = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = azurerm_resource_group.test.name
}

resource "azurerm_network_interface" "test" {
  count               = var.vm_count
  name                = "test-nic-${count.index}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "test-ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  count               = var.vm_count
  name                = "test-vm-${count.index}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  size                = var.vm_size
  admin_username      = "testuser"
  network_interface_ids = [azurerm_network_interface.test[count.index].id]

  os_disk {
    name              = "test-osdisk-${count.index}"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = var.publisher
    offer     = var.image
    sku       = var.sku
    version   = "latest"
  }
  disable_password_authentication = false
  admin_password = random_password.password[count.index].result
}

resource "random_password" "password" {
  count    = var.vm_count
  length   = 16
  special  = true
}

resource "azurerm_network_security_group" "test" {
  name                = "test-nsg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "test" {
  count                       = var.vm_count
  network_interface_id        = azurerm_network_interface.test[count.index].id
  network_security_group_id   = azurerm_network_security_group.test.id
}

resource "azurerm_public_ip" "test" {
  count               = var.vm_count
  name                = "test-publicip-${count.index}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

output "vm_pings" {
  value = {
    for i, nic in azurerm_network_interface.test : 
    "test-vm-${i}" => {
      for j, other_nic in azurerm_network_interface.test :
      "test-vm-${j}" => {
        result = azurerm_linux_virtual_machine.test[i].id != azurerm_linux_virtual_machine.test[j].id ? try(azurerm_network_interface.test[i].private_ip_address != null && azurerm_network_interface.test[j].private_ip_address != null ? 
            tobool(
              can("${azurerm_network_interface.test[i].private_ip_address},${azurerm_network_interface.test[j].private_ip_address}", 5, 60)
            ) : null, null) : null
      }
    }
  }
}
