# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//security/iam-service-centric-permissions-boundary?ref=v1.1.1"
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders()
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
# This boundary only depends on the terraform_state_s3_bucket, arn_region, and aws_account_id
# VPC Name passed for policy path creation since _globals doesn't have vpc_name set
inputs = {
  vpc_name = "${TPL_TERRAFORM_ENV}"
}
