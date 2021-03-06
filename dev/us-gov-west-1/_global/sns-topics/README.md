# Simple Notification Service (SNS) Topics

This directory creates Topics for Amazon's [Simple Notification Service (SNS)](https://aws.amazon.com/sns/) that live 
in `us-east-1`. We need a separate SNS topic specifically in `us-east-1` because Route 53 only sends CloudWatch metrics 
to `us-east-1`, and therefore, all CloudWatch alarms based on Route 53 metrics, and all SNS topics those alarms notify, 
must also live in `us-east-1`.

You can subscribe to this topic in the [SNS Console](https://console.aws.amazon.com/sns/v2/home?region=us-east-1#/topics) 
to be notified of alarms byemail or text message.




## Current configuration

The infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices. Required
  version `>=0.23.2`.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terragrunt.hcl` file.





## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules-multi-account-acme/networking/sns-topics](https://github.com/gruntwork-io/infrastructure-modules-multi-account-acme/tree/master/networking/sns-topics).
When you run Terragrunt, it finds the URL of this module in the `terragrunt.hcl` file, downloads the Terraform code into
a temporary folder, copies all the files in the current working directory (including `terragrunt.hcl`) into the
temporary folder, and runs your Terraform command in that temporary folder.

See the [Terragrunt Remote Terraform configurations
documentation](https://github.com/gruntwork-io/terragrunt#remote-terraform-configurations) for more info.




## Applying changes

To apply changes to the templates in this folder, do the following:

1. Make sure [Terraform](https://www.terraform.io/) and [Terragrunt](https://github.com/gruntwork-io/terragrunt) are
   installed.
1. Configure the secrets specified at the top of `terragrunt.hcl` as environment variables.
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.




## More info

For more info, check out the Readme for this module in [infrastructure-modules-multi-account-acme/networking/sns-topics](https://github.com/gruntwork-io/infrastructure-modules-multi-account-acme/tree/master/networking/sns-topics).
