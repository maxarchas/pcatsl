# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt

  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${TPL_TERRAFORM_STATE_S3_BUCKET}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${TPL_TERRAFORM_STATE_REGION}"
    dynamodb_table = "terraform-locks"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

inputs = merge(
  # Configure Terragrunt to use common vars encoded as yaml to help you keep often-repeated variables (e.g., account ID)
  # DRY. We use yamldecode to merge the maps into the inputs, as opposed to using varfiles due to a restriction in
  # Terraform >=0.12 that all vars must be defined as variable blocks in modules. Terragrunt inputs are not affected by
  # this restriction.
  yamldecode(
    file(find_in_parent_folders("region.yaml", find_in_parent_folders("empty.yaml"))),
  ),
  yamldecode(
    file(find_in_parent_folders("env.yaml", find_in_parent_folders("empty.yaml"))),
  ),
  # Additional global inputs to pass to all modules called in this directory tree.
  {
    # These variables apply to this entire AWS account. They use to be automatically pulled in using the extra_arguments
    # setting in the root terraform.tfvars file's Terragrunt configuration, but now are hardcoded here.
    route53_commercial_account_id     = "${TPL_TERRAFORM_ROUTE53_COMMERCIAL_ACCOUNT_ID}"
    aws_account_id                    = "${TPL_TERRAFORM_AWS_ACCOUNT_ID}"
    aws_account_alias                 = "${TPL_TERRAFORM_ACCOUNT_ALIAS}"

    # The pipeline artifact bucket
    # pipeline_artifact_bucket          = "${TPL_TERRAFORM_PIPELINE_ARTIFACT_BUCKET}"

    # The Transit Gateway Account for GovCloud
    tgw_account_id                    = "${TPL_TERRAFORM_TRANSIT_GATEWAY_ACCOUNT_ID}"

    terraform_state_s3_bucket         = "${TPL_TERRAFORM_STATE_S3_BUCKET}"
    terraform_state_shared_s3_bucket  = "${TPL_TERRAFORM_STATE_SHARED_S3_BUCKET}"
    terraform_state_aws_region        = "${TPL_TERRAFORM_STATE_REGION}"
    shared_services_account_id        = "${TPL_TERRAFORM_SHARED_SERVICES_ACCOUNT_ID}"

    # Golden Goose variables - these variables are the same in each account of a partition.
    # For example, all of dev/stage/prod in commercial would have the same values
    # and all of the dev/stage/prod in govcloud would have the same values
    golden_goose_deployable_bucket_arn = "arn:aws-us-gov:s3:::gg-g-shared-deployable"
    golden_goose_deployable_bucket_id = "gg-g-shared-deployable"
    golden_goose_source_bucket_arn = "arn:aws-us-gov:s3:::gg-g-shared-source"
    golden_goose_source_bucket_id = "gg-g-shared-source"
    golden_goose_ecr_uri_prefix = "877396855103.dkr.ecr.us-gov-west-1.amazonaws.com/gg"
    golden_goose_ecr_arn_prefix = "arn:aws-us-gov:ecr:us-gov-west-1:877396855103:repository/gg"
    golden_goose_build_event_topic_arn = "arn:aws-us-gov:sns:us-gov-west-1:877396855103:gg-g-shared-build-event"
    golden_goose_quality_event_topic_arn = "arn:aws-us-gov:sns:us-gov-west-1:877396855103:gg-g-shared-quality-event"
    golden_goose_deploy_event_topic_arn = "arn:aws-us-gov:sns:us-gov-west-1:877396855103:gg-g-shared-deploy-event"
  },
)

