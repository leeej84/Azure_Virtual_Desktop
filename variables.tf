# Subscription ids
variable "subscription_id" {
  type    = string
  default = "8817c809-4996-4b1c-a7c2-41e960bae57d"
}

# Resources
variable "default_location" {
  type    = string
  default = "uksouth"
}

#Default Tags
variable "default_tags" {
  type = map(any)
  default = {
    environment = "Lab"
    deployed_by = "Terraform"
    event       = "CUGC_July_22"
    reason      = "Citrix_vs_AVD"
  }
}

variable "rg_avdcore" {
  type    = string
  default = "rg-avdcore"
}

variable "rg_shared" {
  type    = string
  default = "rg-shared"
}

variable "rg_hosts" {
  type    = string
  default = "rg-hosts"
}

variable "rg_imagebuild" {
  type    = string
  default = "rg-imagebuild"
}

variable "nsg_avd" {
  type    = string
  default = "nsg-avd"
}

variable "vnet_avd" {
  type    = string
  default = "vnet-avd"
}

variable "la_avd" {
  type    = string
  default = "la-avd"
}

variable "avd_workspace" {
  type    = string
  default = "avd_workspace"
}

variable "avd_hostpool" {
  type    = string
  default = "avd_hostpool"
}

variable "rfc3339" {
  type        = string
  default     = "2022-07-21T12:00:00Z"
  description = "Registration token expiration"
}

variable "avd_sig" {
  type    = string
  default = "avd_sig"
}

variable "avd_gallery" {
  type    = string
  default = "avd_gallery"
}

variable "avd_sharedImage" {
  type    = string
  default = "avd_image"
}

variable "avd_groupName" {
  type    = string
  default = "AVD Users"
}

variable "template_vm" {
  type    = string
  default = "template01"
}


