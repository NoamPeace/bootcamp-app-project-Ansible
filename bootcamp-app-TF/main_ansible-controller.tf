
# Create Resource Group
resource "azurerm_resource_group" "rg_ansible" {
  name     = "${var.prefix}-ResourceGroup-Ansible_Controller"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet_ansible_controller" {
  name                = "${var.prefix}-Vnet-Ansible-Controller"
  address_space       = [var.vnet-cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ansible.name
}



# Create ansible controller subnet
resource "azurerm_subnet" "subnet_ansible_controller" {
  name                 = "${var.prefix}-Subnet-Ansible_Controller"
  resource_group_name  = azurerm_resource_group.rg_ansible.name
  virtual_network_name = azurerm_virtual_network.vnet_ansible_controller.name
  address_prefixes     = ["10.0.0.0/29"]
}

# Create a public IP
resource "azurerm_public_ip" "publicip_ansible_controller" {
  name                = "${var.prefix}-PublicIP-Ansible-Controller"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ansible.name
  allocation_method   = "Static"

}

# Create a network interface for ansible controller VM
resource "azurerm_network_interface" "nic_ansible_controller" {
  name                = "${var.prefix}-NIC1-Ansible-Controller"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ansible.name

  ip_configuration {
    name                          = "bootcamp_Week5-NIC1_Conf_ansible_controller"
    subnet_id                     = azurerm_subnet.subnet_ansible_controller.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.publicip_ansible_controller.id
  }
}


# Create Network Security Group and rules for the ansible controller
resource "azurerm_network_security_group" "nsg_ansible_controller" {
  name                = "${var.prefix}-APP-NSG-Ansible-Controller"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ansible.name


  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
}

# Associate ansible controller subnet to ansible controller subnet_network_security_group
resource "azurerm_subnet_network_security_group_association" "public_ansible_controller" {
  subnet_id                 = azurerm_subnet.subnet_ansible_controller.id
  network_security_group_id = azurerm_network_security_group.nsg_ansible_controller.id
}


# Associate ansible controller network interface to ansible controller public subnet_network_security_group
 resource "azurerm_network_interface_security_group_association" "nsg_nic_ansible_controller" {
   network_interface_id      = azurerm_network_interface.nic_ansible_controller.id
   network_security_group_id = azurerm_network_security_group.nsg_ansible_controller.id
 }



# Create a linux ansible controller virtual machine using virtual machine module
resource "azurerm_virtual_machine" "vm_ansible_controller" {
  name                = "${var.prefix}-VM-Ansible-Controller"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ansible.name
  network_interface_ids = [azurerm_network_interface.nic_ansible_controller.id]
  vm_size               = var.public_vm_size

  storage_os_disk {
    name              = "${var.prefix}-VM_OsDisk-Ansible-Controller"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"

  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "bootcampWeek5VMAnsible"
    admin_username = var.ubuntu_username
    admin_password = random_string.password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
