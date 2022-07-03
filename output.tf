output "azure_virtual_desktop_compute_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg_avdhosts
}

output "azure_virtual_desktop_core_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg_avdcore
}

output "azure_virtual_image_build_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg_avdimagebuild
}

output "azure_virtual_shared_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg_avdshared
}

output "azure_virtual_desktop_host_pool" {
  description = "Name of the Azure Virtual Desktop host pool"
  value       = azurerm_virtual_desktop_host_pool.hostpool
}

output "azurerm_virtual_desktop_application_group" {
  description = "Name of the Azure Virtual Desktop DAG"
  value       = azurerm_virtual_desktop_application_group.dag
}

output "azurerm_virtual_desktop_workspace" {
  description = "Name of the Azure Virtual Desktop workspace"
  value       = azurerm_virtual_desktop_workspace.avd_workspace
}

output "azurerm_public_ip" {
  description = "Details of VPN Public IP"
  value       = azurerm_public_ip.labvpn_ip
}
