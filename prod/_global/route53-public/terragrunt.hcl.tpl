# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//networking/route53-public?ref=v12-1.0.1"
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders()
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  primary_domain_name = "${TPL_TERRAFORM_ACCOUNT_ALIAS}.satcloud.us"
  primary_domain_name_comment = "Managed by Terraform"

  # Route53 items
  route53_account_profile = "${TPL_TERRAFORM_ROUTE53_ACCOUNT_PROFILE}"
}
