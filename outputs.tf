output "name" {
  description = "The name of the ExpressRoute Port resource."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The ExpressRoute Port resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the ExpressRoute Port."
  value       = azapi_resource.this.id
}
