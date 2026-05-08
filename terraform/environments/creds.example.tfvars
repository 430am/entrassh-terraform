# Example credentials file.
#
# These keys are *environment variables* read by the AzureRM / AzureAD
# providers — they are NOT Terraform input variables. To use them, source
# this file (after copying to creds.tfvars and filling in real values)
# before running terraform:
#
#   set -a; source environments/creds.tfvars; set +a
#   terraform plan -var-file=environments/example.tfvars
#
# DO NOT commit a populated creds.tfvars; *.tfvars is gitignored.
# Prefer Azure CLI auth (`az login`) or a Managed Identity / Workload
# Identity Federation in CI over a long-lived client secret.

ARM_SUBSCRIPTION_ID = "00000000-0000-0000-0000-000000000000"
ARM_CLIENT_ID       = "00000000-0000-0000-0000-000000000000"
ARM_CLIENT_SECRET   = "REPLACE_ME"
ARM_TENANT_ID       = "00000000-0000-0000-0000-000000000000"
