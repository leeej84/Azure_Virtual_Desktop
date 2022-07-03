provider "azurerm" {
  features {}
}

# Created Shared Image Gallery
resource "azurerm_shared_image_gallery" "sig" {
  name                = var.avd_gallery
  resource_group_name = azurerm_resource_group.rg_avdimagebuild.name
  location            = var.default_location
  description         = "Shared images for AVD"
  tags                = var.default_tags
}

resource "azurerm_shared_image" "sig" {
  name                = var.avd_sharedImage
  gallery_name        = azurerm_shared_image_gallery.sig.name
  resource_group_name = azurerm_resource_group.rg_avdimagebuild.name
  location            = var.default_location
  tags                = var.default_tags
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win11-21h2-avd-m365"
  }
}

resource "azurerm_network_interface" "template_vm_nic" {
  name                = "${var.template_vm}-nic"
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_avdimagebuild.name
  tags                = var.default_tags

  ip_configuration {
    name                          = "${var.template_vm}-ipcfg"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "template_vm" {
  name                = var.template_vm
  resource_group_name = azurerm_resource_group.rg_avdimagebuild.name
  location            = var.default_location
  tags                = var.default_tags
  size                = "Standard_D4ds_v5"
  admin_username      = "adminuser"
  admin_password      = "P@ssword100!"
  network_interface_ids = [
    azurerm_network_interface.template_vm_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win11-21h2-avd-m365"
    version   = "latest"
  }
}
