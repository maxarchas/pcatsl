# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY:
# https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
    source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//networking/sns-topics?ref=tf12-develop"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  # We need an SNS topic specifically in us-east-1 because Route 53 only sends CloudWatch metrics to us-east-1, and
  # therefore, all CloudWatch alarms based on Route 53 metrics, and all SNS topics those alarms notify, must also live in
  # us-east-1. For all other SNS Topics that are not related to Route53 metrics, create those in a folder under a
  # specific AWS region, not here.
  name = "route53-cloudwatch-alarms"
}
