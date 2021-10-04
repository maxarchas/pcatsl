# Cross-account IAM Roles

This module creates IAM roles that allow users from your other AWS accounts to access this AWS account. This allows you
to define all of your IAM users in a single account (e.g. a `users` account), and use those same credentials to assume 
specific IAM roles in other accounts (e.g. `stage` and `prod` accounts). 

Note that while these templates allow other accounts to access this account, you will also need to add IAM policies in 
those other accounts for users to actually be able to switch between accounts. See the 
[iam-groups module](https://github.com/gruntwork-io/module-security/tree/master/modules/iam-groups) for how to create 
those policies.




## Current configuration

The infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terraform.tfvars` file.




## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules-multi-account-acme/security/iam-cross-account](https://github.com/gruntwork-io/infrastructure-modules-multi-account-acme/tree/master/security/iam-cross-account).
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




## Core concepts

To understand core concepts like how these IAM roles work, how to switch between AWS accounts, and more, see the 
[cross-account-iam-roles module documentation](https://github.com/gruntwork-io/module-security/tree/master/modules/cross-account-iam-roles).