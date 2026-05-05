data "azapi_client_config" "current" {}

resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = "${data.azapi_client_config.current.subscription_resource_id}/resourceGroups/${var.resource_group_name}"
  type      = "Microsoft.Network/ExpressRoutePorts@2025-05-01"
  body = {
    properties = {
      bandwidthInGbps = var.bandwidth_in_gbps
      billingType     = var.billing_type
      encapsulation   = var.encapsulation
      peeringLocation = var.peering_location
      links = length(var.links) > 0 ? [
        for link in var.links : {
          name = link.name
          properties = {
            adminState = link.admin_state
            macSecConfig = link.mac_sec_config != null ? {
              cakSecretIdentifier = link.mac_sec_config.cak_secret_identifier
              cipher              = link.mac_sec_config.cipher
              cknSecretIdentifier = link.mac_sec_config.ckn_secret_identifier
              sciState            = link.mac_sec_config.sci_state
            } : null
          }
        }
      ] : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.etherType",
    "properties.provisioningState",
    "properties.resourceGuid",
    "properties.circuits",
  ]
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = tolist(identity.value.user_assigned_resource_ids)
    }
  }
}

# required AVM resource interfaces
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

module "authorization" {
  source   = "./modules/authorization"
  for_each = var.authorizations

  express_route_port_resource_id = azapi_resource.this.id
  name                           = each.value.name
}

# TODO - review diagnostic settings requirements
# resource "azapi_resource" "diagnostic_setting" {
#   for_each = var.diagnostic_settings

#   type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
#   parent_id = azapi_resource.this.id
#   name      = coalesce(each.value.name, "diag-${var.name}-${each.key}")

#   body = {
#     properties = {
#       workspaceId                 = each.value.workspace_resource_id
#       storageAccountId            = each.value.storage_account_resource_id
#       eventHubAuthorizationRuleId = each.value.event_hub_authorization_rule_resource_id
#       eventHubName                = each.value.event_hub_name
#       marketplacePartnerId        = each.value.marketplace_partner_resource_id
#       logAnalyticsDestinationType = each.value.log_analytics_destination_type
#       logs = concat(
#         [for cat in each.value.log_categories : {
#           category        = cat
#           enabled         = true
#           retentionPolicy = { enabled = false, days = 0 }
#         }],
#         [for grp in each.value.log_groups : {
#           categoryGroup   = grp
#           enabled         = true
#           retentionPolicy = { enabled = false, days = 0 }
#         }]
#       )
#       metrics = [for cat in each.value.metric_categories : {
#         category        = cat
#         enabled         = true
#         retentionPolicy = { enabled = false, days = 0 }
#       }]
#     }
#   }

#   response_export_values = []
# }

