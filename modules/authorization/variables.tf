variable "express_route_port_resource_id" {
  type        = string
  description = "The resource ID of the parent ExpressRoute Port."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the ExpressRoute Port authorization resource."
  nullable    = false
}
