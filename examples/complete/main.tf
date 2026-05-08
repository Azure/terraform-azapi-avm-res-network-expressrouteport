terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.12.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "italynorth"
  name     = module.naming.resource_group.name_unique
}

# Pre-existing user-assigned identity to assign to the ExpressRoute Port.
# The module does not create the identity; it only assigns it.
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "id-erp-avm-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call demonstrating a complete configuration with both
# links enabled and an authorization.
module "test" {
  source = "../../"

  bandwidth_in_gbps = 10
  encapsulation     = "Dot1Q"
  # source             = "Azure/avm-res-network-expressrouteport/azurerm"
  # version            = "~> 0.1"
  location            = azurerm_resource_group.this.location
  name                = "test-erp-avm-${random_string.suffix.result}"
  peering_location    = "Equinix-Singapore-SG1"
  resource_group_name = azurerm_resource_group.this.name
  # Create an authorization on the ExpressRoute Port.
  # An authorization grants an ExpressRoute circuit permission to connect to this port.
  authorizations = {
    primary = {
      name = "auth-${random_string.suffix.result}"
    }
  }
  billing_type     = "MeteredData"
  enable_telemetry = var.enable_telemetry
  links = [
    {
      name        = "link1"
      admin_state = "Disabled"
      mac_sec_config = {
        cipher    = "GcmAes128"
        sci_state = "Disabled"
      }
    },
    {
      name        = "link2"
      admin_state = "Disabled"
      mac_sec_config = {
        cipher    = "GcmAes128"
        sci_state = "Disabled"
      }
    }
  ]
  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }
}
