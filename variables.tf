# Private endpoints are not supported for ExpressRoute Ports.

# variable "diagnostic_settings" {
#   type = map(object({
#     name                                     = optional(string, null)
#     log_categories                           = optional(set(string), [])
#     log_groups                               = optional(set(string), ["allLogs"])
#     metric_categories                        = optional(set(string), ["AllMetrics"])
#     log_analytics_destination_type           = optional(string, "Dedicated")
#     workspace_resource_id                    = optional(string, null)
#     storage_account_resource_id              = optional(string, null)
#     event_hub_authorization_rule_resource_id = optional(string, null)
#     event_hub_name                           = optional(string, null)
#     marketplace_partner_resource_id          = optional(string, null)
#   }))
#   default     = {}
#   description = <<DESCRIPTION
# A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

# - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
# - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
# - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
# - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
# - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
# - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
# - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
# - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
# - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
# - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
# DESCRIPTION
#   nullable    = false

#   validation {
#     condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
#     error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
#   }
#   validation {
#     condition = alltrue(
#       [
#         for _, v in var.diagnostic_settings :
#         v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
#       ]
#     )
#     error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
#   }
# }

# ExpressRoute Port specific variables
variable "bandwidth_in_gbps" {
  type        = number
  description = "Bandwidth of procured ports in Gbps. Typical values are 10, 100, or 400."
  nullable    = false
}

variable "encapsulation" {
  type        = string
  description = "Encapsulation method on physical ports. Possible values are `Dot1Q` and `QinQ`."
  nullable    = false

  validation {
    condition     = contains(["Dot1Q", "QinQ"], var.encapsulation)
    error_message = "encapsulation must be one of: 'Dot1Q', 'QinQ'."
  }
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the ExpressRoute Port resource."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The name must be 2-80 characters, start and end with alphanumeric or underscore, and may contain letters, numbers, underscores, hyphens, and periods."
  }
}

variable "peering_location" {
  type        = string
  description = "The name of the peering location that the ExpressRoute Port is mapped to physically."
  nullable    = false
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "authorizations" {
  type = map(object({
    name = string
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of ExpressRoute Port authorizations to create. The map key is an arbitrary name used to identify the authorization in Terraform and does not affect the Azure resource name.

- `name` - (Required) The name of the authorization resource in Azure.
DESCRIPTION
  nullable    = false
}

variable "billing_type" {
  type        = string
  default     = "MeteredData"
  description = "The billing type of the ExpressRoute Port resource. Possible values are `MeteredData` and `UnlimitedData`."
  nullable    = false

  validation {
    condition     = contains(["MeteredData", "UnlimitedData"], var.billing_type)
    error_message = "billing_type must be one of: 'MeteredData', 'UnlimitedData'."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "links" {
  type = list(object({
    name        = string
    admin_state = optional(string, "Disabled")
    mac_sec_config = optional(object({
      cak_secret_identifier = optional(string, null)
      cipher                = optional(string, null)
      ckn_secret_identifier = optional(string, null)
      sci_state             = optional(string, "Disabled")
    }), null)
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) A list of physical link configurations for the ExpressRoute Port. Each ExpressRoute Port has two links (link1 and link2). If not specified, links remain in their default state.

- `name` - The name of the link (e.g., `link1` or `link2`).
- `admin_state` - (Optional) Administrative state of the physical port. Possible values are `Disabled` and `Enabled`. Defaults to `Disabled`.
- `mac_sec_config` - (Optional) MACsec configuration for the link.
  - `cak_secret_identifier` - (Optional) Key Vault Secret Identifier URL containing the MACsec CAK key.
  - `cipher` - (Optional) MACsec cipher. Possible values are `GcmAes128`, `GcmAes256`, `GcmAesXpn128`, `GcmAesXpn256`.
  - `ckn_secret_identifier` - (Optional) Key Vault Secret Identifier URL containing the MACsec CKN key.
  - `sci_state` - (Optional) SCI mode. Possible values are `Disabled` and `Enabled`. Defaults to `Disabled`.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for l in var.links : contains(["Disabled", "Enabled"], l.admin_state)])
    error_message = "Each link admin_state must be one of: 'Disabled', 'Enabled'."
  }
  validation {
    condition = alltrue([
      for l in var.links : l.mac_sec_config == null ? true :
      l.mac_sec_config.cipher == null ? true :
      contains(["GcmAes128", "GcmAes256", "GcmAesXpn128", "GcmAesXpn256"], l.mac_sec_config.cipher)
    ])
    error_message = "Each link mac_sec_config.cipher must be one of: 'GcmAes128', 'GcmAes256', 'GcmAesXpn128', 'GcmAesXpn256'."
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
- `principal_type` - The type of the principal_id. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
