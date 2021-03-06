# Dev VPC

This directory creates a [Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/) that can be used for non-production
workloads (i.e. a testing or pre-prod environment).

The resources that are created include:

1. The VPC itself.
1. Subnets, which are isolated subdivisions within the VPC. There are 3 "tiers" of subnets: public, private app, and
   private persistence.
1. Route tables, which provide routing rules for the subnets.
1. Internet Gateways to route traffic to the public Internet from public subnets.
1. NATs to route traffic to the public Internet from private subnets.
1. Network ACLs that control what traffic can go in and out of each subnet.
1. VPC Peering connection that allows limited access from the Mgmt VPC.

## Current configuration

The VPC infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terraform.tfvars` file.

## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules-multi-account-acme/networking/vpc-app](https://github.com/gruntwork-io/infrastructure-modules-multi-account-acme/tree/master/networking/vpc-app).
When you run Terragrunt, it finds the URL of this module in the `terraform.tfvars` file, downloads the Terraform code into
a temporary folder, copies all the files in the current working directory (including `terraform.tfvars`) into the
temporary folder, and runs your Terraform command in that temporary folder.

See the [Terragrunt Remote Terraform configurations
documentation](https://github.com/gruntwork-io/terragrunt#remote-terraform-configurations) for more info.

## Applying changes

To apply changes to the templates in this folder, do the following:

1. Make sure [Terraform](https://www.terraform.io/) and [Terragrunt](https://github.com/gruntwork-io/terragrunt) are
   installed.
1. Configure the secrets specified at the top of `terraform.tfvars` as environment variables.
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.

## More info

For more info, check out the Readme for this module in [infrastructure-modules-multi-account-acme/networking/vpc-app](https://github.com/gruntwork-io/infrastructure-modules-multi-account-acme/tree/master/networking/vpc-app).