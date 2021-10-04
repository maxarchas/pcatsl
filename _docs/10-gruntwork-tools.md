# Gruntwork Tools

Just in case you missed them earlier in the tutorial, here are some useful Gruntwork tools:

- **[aws-auth](https://github.com/maxar-infrastructure/module-security/tree/master/modules/aws-auth):** A bash script that
makes it easy to switch between multiple AWS accounts and use MFA in the CLI.

- **[gruntkms](https://github.com/maxar-infrastructure/gruntkms)**: Use this tool to to encrypt/decrypt secrets with 
  [Amazon's Key Management Service](https://aws.amazon.com/documentation/kms/) using a one-line command.

- **[terragrunt](https://github.com/maxar-infrastructure/terragrunt)**: Terragrunt is a thin wrapper for Terraform that provides
  extra tools for working with multiple Terraform modules. You should always use Terragrunt with this repo.

- **[ssh-grunt](https://github.com/maxar-infrastructure/module-security/tree/master/modules/ssh-grunt)**: Your EC2 Instances use
  this tool to allow SSH access to be managed via the IAM User console.

- **[openvpn-admin](https://github.com/maxar-infrastructure/package-openvpn/releases)**: Use this tool to generate the 
  configuration file you need to access the OpenVPN server.  
- **[kubergrunt](https://github.com/maxar-infrastructure/kubergrunt)**: A single standalone go binary with a collection of
  commands that fill in the gaps between Terraform, Helm, and Kubectl.

To see a full list of all Gruntwork Infrastructure Packages and tools, see the [Gruntwork Table of 
Contents](https://github.com/maxar-infrastructure/toc).


## Expected Tool Versions

Most of the tools listed here are not version constrained: you should be able to use the newest version without running
into any issues. With that said, some tools like Terraform and Helm depend on a specific version due to the way internal
metadata is managed. For example, the Terraform state written using version `0.12.6` is only readable by Terraform
version `0.12.6`. As such, it is important to use the version of the tool that is expected by the Reference
Architecture.

Here is a list of the tools that have these constraints and the expected versions for this Reference Architecture:

- Terraform: `0.13.5`
- Terragrunt: `>= 0.23.2`
- Helm: `v3.4.1`
- kubergrunt: `>= v0.6.9`
- kubectl: `>= v1.17.0`


## Next steps

Next up, you'll learn how to [deploy a docker service with the Reference Architecture](11-deploying-a-docker-service.md).
