resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.express_route_port_resource_id
  type      = "Microsoft.Network/expressRoutePorts/authorizations@2025-05-01"
  body      = {}
  response_export_values = [
    "properties.authorizationKey",
    "properties.authorizationUseStatus",
  ]
}
