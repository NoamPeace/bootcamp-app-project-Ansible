# Get data from tfvars file
# data "tfvars_file" "pgtfvars" {
#   filename = "pg.tfvars"
# }

#Get data from vnet
data "azurerm_virtual_network" "data_vnet_staging" {
  name                = azurerm_virtual_network.vnet_staging.name
  resource_group_name = azurerm_resource_group.rg_stage.name
}
#Get data from load balancer
data "azurerm_lb" "data_lb_staging" {
  name                = azurerm_lb.publicLB_staging.name
  resource_group_name = azurerm_resource_group.rg_stage.name
}
#Get data from backend address pool
data "azurerm_lb_backend_address_pool" "data_pool_staging" {
  name            = azurerm_lb_backend_address_pool.backend_address_pool_public_staging.name
  loadbalancer_id = data.azurerm_lb.data_lb_staging.id
}


#Get ip data for staging
data "azurerm_public_ip" "ip_staging" {
  name                = azurerm_public_ip.publicip_staging.name
  resource_group_name = azurerm_resource_group.rg_stage.name
}


#Get ip data for production
data "azurerm_public_ip" "ip_production" {
  name                = azurerm_public_ip.publicip_production.name
  resource_group_name = azurerm_resource_group.rg_prod.name
}

#Get ip data for ansible controller
data "azurerm_public_ip" "ip_ansible_controller" {
  name                = azurerm_public_ip.publicip_ansible_controller.name
  resource_group_name = azurerm_resource_group.rg_ansible.name
}