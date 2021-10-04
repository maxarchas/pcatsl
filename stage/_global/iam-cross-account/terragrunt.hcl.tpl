terraform {
  source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//security/iam-cross-account?ref=v12-1.1.0"
}

include {
  path = find_in_parent_folders()
}

# If you delete iam-cross-account, you may lose all IAM access to this account, so we set prevent destroy here to
# prevent accidental lock out. If you really want to run destroy on this module, remove this flag.
prevent_destroy = true

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  should_require_mfa = false
  dev_permitted_services = ["ec2", "s3", "rds", "dynamodb", "elasticache"]
  allow_read_only_access_from_other_account_arns = [
    "${TPL_TERRAFORM_SECURITY_ACCOUNT_TRUST}", # security account
  ]

  allow_billing_access_from_other_account_arns = [
    "${TPL_TERRAFORM_SECURITY_ACCOUNT_TRUST}", # security account
  ]

  allow_ssh_grunt_access_from_other_account_arns = []
  allow_dev_access_from_other_account_arns = [
    "${TPL_TERRAFORM_SECURITY_ACCOUNT_TRUST}", # security account
  ]

  allow_full_access_from_other_account_arns = [
    "${TPL_TERRAFORM_SECURITY_ACCOUNT_TRUST}", # security account
  ]

  auto_deploy_permissions = ["cloudwatch:*", "logs:*", "dynamodb:*", "ecr:*", "ecs:*", "route53:*", "s3:*", "autoscaling:*", "elasticloadbalancing:*", "iam:GetRole", "iam:GetRolePolicy", "iam:PassRole"]

  allow_auto_deploy_from_other_account_arns = [
    "${TPL_TERRAFORM_SHARED_ACCOUNT_TRUST}", # shared-services
  ]
}
