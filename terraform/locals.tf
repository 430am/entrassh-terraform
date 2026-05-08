locals {
  common_tags = merge(var.tags, {
    component   = "demonstration"
    deployed_by = data.azuread_user.current_user.display_name
  })
}