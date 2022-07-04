resource "azurerm_network_interface" "CC1-NIC" {
  name                = "${var.CloudConnectors.ccName}-nic"
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_avdshared.name
  tags                = var.default_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "CC1" {
  name                = var.CloudConnectors.ccName
  computer_name       = var.CloudConnectors.ccName
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_avdshared.name
  tags                = var.default_tags
  size                = var.CloudConnectors.vmSize
  admin_username      = var.VMCommonSettings.localadminuser
  admin_password      = var.VMCommonSettings.localpassword
  network_interface_ids = [
    azurerm_network_interface.CC1-NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "join-domain" {
  name                 = "join-domain"
  virtual_machine_id   = azurerm_windows_virtual_machine.CC1.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU
  settings = <<SETTINGS
    {
        "Name": "${var.DomainJoin.domain}",
        "OUPath": "",
        "User": "${var.DomainJoin.username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.DomainJoin.password}"
    }
SETTINGS
  provisioner "local-exec" {
    command = "az vm run-command invoke --command-id RunPowerShellScript --name ${var.CloudConnectors.ccName} -g ${azurerm_resource_group.rg_avdshared.name} --scripts @InstallCloudConnector.ps1 --parameters APIID=${var.CloudConnectors.APIID} APIKey=${var.CloudConnectors.APIKey} CustomerName=${var.CloudConnectors.CustomerName}"
  }
}