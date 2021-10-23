# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  availability_set_id   = var.availability_set_id
  network_interface_ids = var.network_interface_ids
  vm_size               = var.public_vm_size

  storage_os_disk {
    name              = var.storage_os_disk_name
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
    computer_name  = var.computer_name
    admin_username = var.ubuntu_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
