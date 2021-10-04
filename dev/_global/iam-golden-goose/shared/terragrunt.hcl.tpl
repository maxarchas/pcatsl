# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//security/iam-golden-goose?ref=v1.1.1"
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
  gg_arn_region="${TPL_TERRAFORM_ARN_REGION}"
  gg_account_id  = "${TPL_TERRAFORM_SHARED_SERVICES_ACCOUNT_ID}"
  gg_env_name = "shared"

  tags = {
    CostCenter = "M210"
    Customer = "IT"
    Request = "adhoc"
    Project = "golden-goose"
    Contact = "dl-devops-production@digitalglobe.com"
    Environment = "shared"
    Department = "IT"
    Component = "gg-deploy-infra-live"
    Service = "ggdil"
    RunTime = "24_7"
  }
}
