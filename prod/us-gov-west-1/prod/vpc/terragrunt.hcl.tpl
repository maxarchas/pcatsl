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

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//networking/vpc-app-no-mgmt?ref=v1.1.51"
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders()
}

# When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
dependencies {
  paths = ["../../mgmt/vpc"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  cidr_block = "${TPL_TERRAFORM_VPC_CIDR_BLOCK}"

  num_nat_gateways        = ${TPL_TERRAFORM_VPC_NUM_NAT_GATEWAYS}

  allow_private_persistence_internet_access = true
  allow_access_from_mgmt_vpc = false
  create_dns_forwarder = false

  create_public_subnets = true
  create_private_app_subnets = true
  create_private_persistence_subnets = true

  # Example configs for assigning ranges to subnets explicitly
  #public_subnet_cidr_blocks = {
  #    AZ-0 = "10.0.0.0/27"
  #    AZ-1 = "10.0.0.32/27"
  #    AZ-2 = "10.0.0.64/27"
  #}

  #private_app_subnet_cidr_blocks = {
  #    AZ-0 = "10.0.1.0/24"
  #    AZ-1 = "10.0.2.0/24"
  #    AZ-2 = "10.0.3.0/24"
  #}

  #private_persistence_subnet_cidr_blocks = {
  #    AZ-0 = "10.0.0.96/27"
  #    AZ-1 = "10.0.0.128/27"
  #    AZ-2 = "10.0.0.160/27"
  #}

  kms_key_user_iam_arns = [
    "${TPL_TERRAFORM_VPC_KMS_IAM_ARN}",
    "${TPL_TERRAFORM_VPC_KMS_IAM_ARN_LOCAL_ACCOUNT}",
  ]

  custom_nacl_rules_app = [
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "false"
      cidr_block = "10.0.0.0/8"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "true"
      cidr_block = "10.0.0.0/8"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "false"
      cidr_block = "172.16.0.0/12"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "true"
      cidr_block = "172.16.0.0/12"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "false"
      cidr_block = "192.168.0.0/16"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "true"
      cidr_block = "192.168.0.0/16"
    }
  ]

  custom_nacl_rules_persistence = [
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "false"
      cidr_block = "10.0.0.0/8"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "true"
      cidr_block = "10.0.0.0/8"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "false"
      cidr_block = "172.16.0.0/12"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "true"
      cidr_block = "172.16.0.0/12"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "false"
      cidr_block = "192.168.0.0/16"
    },
    {
      protocol   = "-1",
      from_port  = "0",
      to_port    = "65535"
      egress     = "true"
      cidr_block = "192.168.0.0/16"
    }
  ]
}
