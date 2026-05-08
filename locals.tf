locals {
  managed_identities = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
    this = {
      type                       = "UserAssigned"
      user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
    }
  } : {}
  role_definition_resource_substring = "providers/Microsoft.Authorization/roleDefinitions"
}
