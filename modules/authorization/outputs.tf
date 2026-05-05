output "authorization_key" {
  description = "The authorization key for the ExpressRoute Port authorization."
  sensitive   = true
  value       = try(azapi_resource.this.output.properties.authorizationKey, null)
}

output "authorization_use_status" {
  description = "The use status of the ExpressRoute Port authorization. Possible values are `Available` and `InUse`."
  value       = try(azapi_resource.this.output.properties.authorizationUseStatus, null)
}

output "resource_id" {
  description = "The resource ID of the ExpressRoute Port authorization."
  value       = azapi_resource.this.id
}
