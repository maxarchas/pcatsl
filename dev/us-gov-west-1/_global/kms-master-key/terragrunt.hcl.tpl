# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//security/kms-master-key?ref=v12-1.1.0"
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders()
}

TPL_TERRAFORM_VPC_KMS_IAM_ARN_LOCAL_ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
# This boundary only depends on the terraform_state_s3_bucket, arn_region, and aws_account_id
# VPC Name passed for policy path creation since _globals doesn't have vpc_name set
inputs = {
  cmk_name = "${TPL_TERRAFORM_KMS_CMK_NAME}"
  cmk_administrator_iam_arns = ["${TPL_TERRAFORM_KMS_CMK_ADMIN_ARN}"]
  cmk_user_iam_arns = ["${TPL_TERRAFORM_KMS_IAM_ARN}"]
  allow_manage_key_permissions_with_iam = true
}
