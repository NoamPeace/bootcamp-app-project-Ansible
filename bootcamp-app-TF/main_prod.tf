
# Create Resource Group
resource "azurerm_resource_group" "rg_prod" {
  name     = "${var.prefix}-ResourceGroup-Production"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet_production" {
  name                = "${var.prefix}-Vnet-Production"
  address_space       = [var.vnet-cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name
}



# Create 2 subnet :Public and Private
resource "azurerm_subnet" "subnet_production" {
  name                 = var.subnet_name[count.index]
  resource_group_name  = azurerm_resource_group.rg_prod.name
  virtual_network_name = azurerm_virtual_network.vnet_production.name
  address_prefixes     = [var.subnet_prefix[count.index]]
  count                = 2
}

# Create a public IP
resource "azurerm_public_ip" "publicip_production" {
  name                = "${var.prefix}-PublicIP-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name
  allocation_method   = "Static"

}




#Create a Load Balancer
resource "azurerm_lb" "publicLB_production" {
  name                = "${var.prefix}-LoadBalancer-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-PublicIPAddress-Production"
    public_ip_address_id = azurerm_public_ip.publicip_production.id
  }
}

#Create a backend address pool for the load balancer
resource "azurerm_lb_backend_address_pool" "backend_address_pool_public_production" {
  loadbalancer_id = azurerm_lb.publicLB_production.id
  name            = "${var.prefix}-Backend_Address_Pool-Production"

}


# Delay before network interfaces creation for 30 seconds
resource "null_resource" "delay_nics_production" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  triggers = {
    "before" = "${azurerm_network_interface.nic_production.id}"
  }
}



# Create a network interface for first VM
resource "azurerm_network_interface" "nic_production" {
  name                = "${var.prefix}-NIC1-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  ip_configuration {
    name                          = "bootcamp_Week5-NIC1_Conf_production"
    subnet_id                     = azurerm_subnet.subnet_production[0].id
    private_ip_address_allocation = "dynamic"
  }
}




# Create a network interface for second VM
resource "azurerm_network_interface" "nic2_production" {
  name                = "${var.prefix}-NIC2-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  ip_configuration {
    name                          = "bootcamp_Week5-NIC2_Conf_production"
    subnet_id                     = azurerm_subnet.subnet_production[0].id
    private_ip_address_allocation = "dynamic"
  }
}


# Create a network interface for third VM
resource "azurerm_network_interface" "nic3_production" {
  name                = "${var.prefix}-NIC3-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  ip_configuration {
    name                          = "${var.prefix}-NIC3_Conf_Production"
    subnet_id                     = azurerm_subnet.subnet_production[0].id
    private_ip_address_allocation = "dynamic"
  }
}

# Associate network interface1 to the load balancer backend address pool
 resource "azurerm_network_interface_backend_address_pool_association" "nic_back_association_production" {
   network_interface_id    = azurerm_network_interface.nic_production.id
   ip_configuration_name   = azurerm_network_interface.nic_production.ip_configuration[0].name
   backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public_production.id
 }
# Associate network interface2 to the load balancer backend address pool
 resource "azurerm_network_interface_backend_address_pool_association" "nic2_back_association_production" {
   network_interface_id    = azurerm_network_interface.nic2_production.id
   ip_configuration_name   = azurerm_network_interface.nic2_production.ip_configuration[0].name
   backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public_production.id
 }
# Associate network interface3 to the load balancer backend address pool
 resource "azurerm_network_interface_backend_address_pool_association" "nic3_back_association_production" {
   network_interface_id    = azurerm_network_interface.nic3_production.id
   ip_configuration_name   = azurerm_network_interface.nic3_production.ip_configuration[0].name
   backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public_production.id
 }





#Create load balancer probe for port 8080
resource "azurerm_lb_probe" "lb_probe_production" {
  name                = "${var.prefix}-LB_tcpProbe-Production"
  resource_group_name = azurerm_resource_group.rg_prod.name
  loadbalancer_id     = azurerm_lb.publicLB_production.id
  protocol            = "HTTP"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
  request_path        = "/"

}




#Create load balancer rule for port 8080
resource "azurerm_lb_rule" "bootcamp_Week5-LB_rule8080_production" {
  resource_group_name            = azurerm_resource_group.rg_prod.name
  loadbalancer_id                = azurerm_lb.publicLB_production.id
  name                           = "LBRule-Production"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.publicLB_production.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb_probe_production.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool_public_production.id
}





#Create public availability set
resource "azurerm_availability_set" "availability_set1_production" {
  name                = "${var.prefix}-AVset-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name

}




# Create Network Security Group and rules for the app
resource "azurerm_network_security_group" "nsg_production" {
  name                = "${var.prefix}-APP-NSG-Production"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_prod.name


  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = data.azurerm_public_ip.ip_production.ip_address
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Port_8080"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}




#Associate subnet to subnet_network_security_group
resource "azurerm_subnet_network_security_group_association" "public_production" {
  subnet_id                 = azurerm_subnet.subnet_production[0].id
  network_security_group_id = azurerm_network_security_group.nsg_production.id
}


# Associate network interface1 to public subnet_network_security_group
 resource "azurerm_network_interface_security_group_association" "nsg_nic_production" {
   network_interface_id      = azurerm_network_interface.nic_production.id
   network_security_group_id = azurerm_network_security_group.nsg_production.id
 }
# Associate network interface2 to public subnet_network_security_group
 resource "azurerm_network_interface_security_group_association" "nsg_nic2_production" {
   network_interface_id      = azurerm_network_interface.nic2_production.id
   network_security_group_id = azurerm_network_security_group.nsg_production.id
 }
# Associate network interface3 to public subnet_network_security_group
 resource "azurerm_network_interface_security_group_association" "nsg_nic3_production" {
   network_interface_id      = azurerm_network_interface.nic3_production.id
   network_security_group_id = azurerm_network_security_group.nsg_production.id
 }
# Associate db network interface to db subnet_network_security_group
#  resource "azurerm_network_interface_security_group_association" "dbnsg" {
#    network_interface_id      = azurerm_network_interface.dbnic.id
#    network_security_group_id = azurerm_network_security_group.dbnsg.id
#  }



#Create Postgresql Server
resource "azurerm_postgresql_server" "postgres_production" {
  name                = lower("${var.prefix}-db-production")
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.pg_admin
  administrator_login_password = var.pg_admin_password
  version                      = "11"
  ssl_enforcement_enabled      = false
}




#Create Postgres firewall rule
resource "azurerm_postgresql_firewall_rule" "postgres_firewall_production" {
  name                = lower("${var.prefix}-db-firewall-production")
  resource_group_name = azurerm_resource_group.rg_prod.name
  server_name         = azurerm_postgresql_server.postgres_production.name
  start_ip_address    = data.azurerm_public_ip.ip_production.ip_address
  end_ip_address      = data.azurerm_public_ip.ip_production.ip_address
}




# Create a linux application virtual machine 1 using virtual machine module
module "linux_virtual_machine_module_appvm1_production" {
  source = "../tf-modules/vm-module"

  vm_name               = "${var.prefix}-AppVM1-Production"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg_prod.name
  public_vm_size        = var.public_vm_size
  availability_set_id   = azurerm_availability_set.availability_set1_production.id
  network_interface_ids = [azurerm_network_interface.nic_production.id]

  storage_os_disk_name = "${var.prefix}-AppVM1_OsDisk-Production"
  computer_name        = "bootcampWeek5VM1Prod"
  ubuntu_username      = var.ubuntu_username
  admin_password       = random_string.password.result
}

# resource "azurerm_virtual_machine_extension" "app1_terraform" {
#   name                 = "VM1_customscript"
#   virtual_machine_id   = azurerm_virtual_machine.vm.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"
#
#   settings = <<SETTINGS
#    {
#        "fileUris": ["https://raw.githubusercontent.com/NoamPeace/bootcamp-app-project-TF/main/vm-scripts/appvm-script.sh"],
#        "commandToExecute": "appvm-script.sh ${join(" ", [data.azurerm_public_ip.ip.ip_address, var.okta_url, var.okta_clientid, var.okta_secret, "replace_with_data_domain_of_db", var.pg_admin, var.pg_admin_password, var.ubuntu_username])}",
#    }
# SETTINGS
# }


# Create a linux application virtual machine 2 using virtual machine module
module "linux_virtual_machine_module_appvm2_production" {
  source = "../tf-modules/vm-module"

  vm_name               = "${var.prefix}-AppVM2-Production"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg_prod.name
  public_vm_size        = var.public_vm_size
  availability_set_id   = azurerm_availability_set.availability_set1_production.id
  network_interface_ids = [azurerm_network_interface.nic2_production.id]

  storage_os_disk_name = "${var.prefix}-AppVM2_OsDisk-Production"
  computer_name        = "bootcampWeek5VM2Prod"
  ubuntu_username      = var.ubuntu_username
  admin_password       = random_string.password.result
}

# resource "azurerm_virtual_machine_extension" "app2_terraform" {
#   name                 = "VM2_customscript"
#   virtual_machine_id   = azurerm_virtual_machine.vm2.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"
#
#   settings = <<SETTINGS
#     {
#         "fileUris": ["https://raw.githubusercontent.com/NoamPeace/bootcamp-app-project-TF/main/vm-scripts/appvm-script.sh"],
#         "commandToExecute": "bash appvm-script.sh ${data.azurerm_public_ip.ip.ip_address} ${var.okta_url} ${var.okta_clientid} ${var.okta_secret} replace_with_data_domain_of_db ${var.pg_admin} ${var.pg_admin_password} ${var.ubuntu_username}"
#     }
# SETTINGS
# }


# Create a linux application virtual machine 3 using virtual machine module
module "linux_virtual_machine_module_appvm3_production" {
  source = "../tf-modules/vm-module"

  vm_name               = "${var.prefix}-AppVM3-Production"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg_prod.name
  public_vm_size        = var.public_vm_size
  availability_set_id   = azurerm_availability_set.availability_set1_production.id
  network_interface_ids = [azurerm_network_interface.nic3_production.id]

  storage_os_disk_name = "${var.prefix}-AppVM3_OsDisk-Production"
  computer_name        = "bootcampWeek5VM3Prod"
  ubuntu_username      = var.ubuntu_username
  admin_password       = random_string.password.result
}


# resource "azurerm_virtual_machine_extension" "app3_terraform" {
#   name                 = "VM3_customscript"
#   virtual_machine_id   = azurerm_virtual_machine.vm3.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"
#
#   settings = <<SETTINGS
#     {
#         "fileUris": ["https://raw.githubusercontent.com/NoamPeace/bootcamp-app-project-TF/main/vm-scripts/appvm-script.sh"],
#         "commandToExecute": "bash appvm-script.sh ${data.azurerm_public_ip.ip.ip_address} ${var.okta_url} ${var.okta_clientid} ${var.okta_secret} replace_with_data_domain_of_db ${var.pg_admin} ${var.pg_admin_password} ${var.ubuntu_username}"
#     }
# SETTINGS
# }

