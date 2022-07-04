# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.10.0"

    }
  }
}

#Provider and subscription
provider "azurerm" {
  alias           = "defaultsub"
  subscription_id = var.subscription_id
  features {}
}

#Resource groups for all resources
resource "azurerm_resource_group" "rg_avdshared" {
  provider = azurerm.defaultsub
  name     = var.rg_shared
  location = var.default_location
  tags     = var.default_tags
}

resource "azurerm_resource_group" "rg_avdhosts" {
  provider = azurerm.defaultsub
  name     = var.rg_hosts
  location = var.default_location
  tags     = var.default_tags
}

resource "azurerm_resource_group" "rg_avdimagebuild" {
  provider = azurerm.defaultsub
  name     = var.rg_imagebuild
  location = var.default_location
  tags     = var.default_tags
}

resource "azurerm_resource_group" "rg_avdcore" {
  provider = azurerm.defaultsub
  name     = var.rg_avdcore
  location = var.default_location
  tags     = var.default_tags
}


#NSG for AVD
resource "azurerm_network_security_group" "nsg_avd" {
  name                = var.nsg_avd
  provider            = azurerm.defaultsub
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_avdshared.name
  tags                = var.default_tags
}

#VNet for AVD
resource "azurerm_virtual_network" "vnet_avd" {
  name                = var.vnet_avd
  provider            = azurerm.defaultsub
  location            = var.default_location
  tags                = var.default_tags
  resource_group_name = azurerm_resource_group.rg_avdshared.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["192.168.1.10", "8.8.8.8"]
}

#Subnet within VNET
resource "azurerm_subnet" "subnet1" {
  provider             = azurerm.defaultsub
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg_avdshared.name
  virtual_network_name = azurerm_virtual_network.vnet_avd.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Subnet within VNET
resource "azurerm_subnet" "GatewaySubnet" {
  provider             = azurerm.defaultsub
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg_avdshared.name
  virtual_network_name = azurerm_virtual_network.vnet_avd.name
  address_prefixes     = ["10.0.10.0/24"]
}

#Deploy AVD Workspace and Host Pools##
resource "azurerm_virtual_desktop_workspace" "avd_workspace" {
  provider            = azurerm.defaultsub
  name                = var.avd_workspace
  resource_group_name = azurerm_resource_group.rg_avdcore.name
  location            = var.default_location
  tags                = var.default_tags
  friendly_name       = "AVD Workspace"
  description         = "AVD Workspace"
}

#Hotspool Creation
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  provider                 = azurerm.defaultsub
  resource_group_name      = azurerm_resource_group.rg_avdcore.name
  location                 = var.default_location
  tags                     = var.default_tags
  name                     = var.avd_hostpool
  friendly_name            = var.avd_hostpool
  validate_environment     = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "AVD HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
}

#Registration info for the hostpool
resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  provider        = azurerm.defaultsub
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.rfc3339
}

#Application Group
resource "azurerm_virtual_desktop_application_group" "dag" {
  provider            = azurerm.defaultsub
  resource_group_name = azurerm_resource_group.rg_avdcore.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  location            = var.default_location
  tags                = var.default_tags
  type                = "Desktop"
  name                = "AVD-dag"
  friendly_name       = "Desktop AppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.avd_workspace]

}

#App group association with HostPool
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd-dag" {
  provider             = azurerm.defaultsub
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.avd_workspace.id

}

#Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "la_avd" {
  provider            = azurerm.defaultsub
  name                = var.la_avd
  location            = var.default_location
  tags                = var.default_tags
  resource_group_name = azurerm_resource_group.rg_avdshared.name
  sku                 = "PerGB2018"
}

# diagnostic settings for workspace
resource "azurerm_monitor_diagnostic_setting" "diag_workspace" {
  provider                   = azurerm.defaultsub
  name                       = "WorkspaceDiagnostics"
  target_resource_id         = azurerm_virtual_desktop_workspace.avd_workspace.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la_avd.id

  log {
    category = "Error"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Checkpoint"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Feed"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Management"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
}

#Diagnostic settings for the host pool
data "azurerm_monitor_diagnostic_categories" "hostpool_categories" {
  provider    = azurerm.defaultsub
  resource_id = azurerm_virtual_desktop_host_pool.hostpool.id
}

resource "azurerm_monitor_diagnostic_setting" "diag_hostpool" {
  provider                   = azurerm.defaultsub
  name                       = "HostPoolDiagnostics"
  target_resource_id         = azurerm_virtual_desktop_host_pool.hostpool.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la_avd.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.hostpool_categories.logs
    content {
      category = log.value
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.hostpool_categories.metrics
    content {
      category = metric.value
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
}

#Group to assign to AVD DAG
resource "azuread_group" "avd_group" {
  display_name     = var.avd_groupName
  security_enabled = true
}

#Deploy Bastion
resource "azurerm_subnet" "AzureBastionSubnet" {
  provider             = azurerm.defaultsub
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg_avdshared.name
  virtual_network_name = azurerm_virtual_network.vnet_avd.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vnet_bastion_ip" {
  provider            = azurerm.defaultsub
  name                = var.bastion_ip
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_avdshared.name
  tags                = var.default_tags
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion_service" {
  provider            = azurerm.defaultsub
  name                = var.bastion_service
  location            = var.default_location
  tags                = var.default_tags
  resource_group_name = azurerm_resource_group.rg_avdshared.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.vnet_bastion_ip.id
  }
}