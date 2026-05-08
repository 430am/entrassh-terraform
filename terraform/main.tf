data "azuread_user" "current_user" {
  object_id = data.azurerm_client_config.current.object_id
}

data "azurerm_client_config" "current" {}

# Generate a random suffix to keep names unique across runs / regions.
resource "random_pet" "naming" {
  length    = 2
  separator = ""
}

# Random password used as the local admin fallback on each VM. The
# value is stored in state (marked sensitive) — the intent is that
# end-users sign in with Entra ID, not with this credential.
#
# NOTE: when the AzureRM provider exposes write-only support for
# admin_password on the VM resources, switch this to an `ephemeral`
# block and use admin_password_wo / admin_password_wo_version on the
# VMs to keep the secret out of state.
resource "random_password" "vm_admin" {
  length  = 20
  special = true
  upper   = true
  lower   = true
  numeric = true

  min_special = 2
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${random_pet.naming.id}-rg"
  tags     = local.common_tags
}

# Grant the configured principal the role required to use Entra ID
# login on the VMs deployed below. Defaults to the identity Terraform
# is running as, which works for both interactive (az login) and
# service-principal authentication.
resource "azurerm_role_assignment" "login_role" {
  principal_id         = coalesce(var.login_principal_id, data.azurerm_client_config.current.object_id)
  role_definition_name = "Virtual Machine Administrator Login"
  scope                = azurerm_resource_group.rg.id
}