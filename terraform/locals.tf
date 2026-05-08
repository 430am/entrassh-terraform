locals {
  common_tags = merge(var.tags, {
    component   = "demonstration"
    deployed_by = data.azurerm_client_config.current.object_id
  })
}