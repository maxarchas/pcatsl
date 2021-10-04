# Accounts and Auth

In the last section, you learned about connecting to your servers using [SSH and VPN](08-ssh-vpn.md). In this section,
you'll learn about connecting to your AWS accounts:

* [Auth basics](#auth-basics)
* [Account setup](#account-setup)
* [Authenticating](#authenticating)
* [Kubernetes RBAC Roles and Helm Authentication](#kubernetes-rbac-roles-and-helm-authentication)
    * [RBAC basics](#rbac-basics)
    * [Relation to IAM roles](#relation-to-iam-roles)
    * [Namespaces and RBAC](#namespaces-and-rbac)
    * [Accessing the cluster](#accessing-the-cluster)
        * [Terragrunt / Terraform](#terragrunt--terraform)
        * [Kubectl](#kubectl)
        * [Helm](#helm)





## Auth basics

For an overview of AWS authentication, including how to authenticate on the command-line, we **strongly** recommend
reading [A Comprehensive Guide to Authenticating to AWS on the Command
Line](https://blog.gruntwork.io/a-comprehensive-guide-to-authenticating-to-aws-on-the-command-line-63656a686799).




## Account setup

Each of your environments (e.g., stage, prod) is in a separate AWS account. This gives you more fine grained control
over who can access what and improves isolation and security, as a mistake or breach in one account is unlikely to
affect the others. The accounts are:

* **dev**: `087285199408`
* **master**: `087285199408`
* **prod**: `087285199408`
* **security**: `087285199408`
* **shared-services**: `087285199408`
* **stage**: `087285199408`


Note that all IAM users are deployed in a single account called "Security." The idea is that you log into the Security
account and, if you need to do something in one of the other accounts, you "switch" to it by assuming an IAM Role in
that account (if you've been granted the necessary permissions).

* [Switching accounts prerequisites](#switching-accounts-prerequisites)
* [Switching accounts in the AWS console](#switching-accounts-in-the-aws-console)
* [Switching accounts with CLI tools](#switching-accounts-with-cli-tools)


### Switching accounts prerequisites

If you are logged in as an IAM user in account A and you want to switch to account B, you need the following:

1. Account B must have an IAM role that explicitly allows your IAM user in account A (or all IAM users in account A)
   to assume that IAM role. We have already set this up in all accounts using the [cross-account-iam-roles
   module](https://github.com/maxar-infrastructure/module-security/tree/master/modules/cross-account-iam-roles).

1. Your IAM user in account A must have the proper IAM permissions to assume roles in account B. We have created IAM
   groups with these permissions using the [iam-groups
   module](https://github.com/maxar-infrastructure/module-security/tree/master/modules/iam-groups). Typically, these IAM groups
   using the naming convention `_account.xxx`, where `xxx` is the name of an account you can switch to (e.g.
   `_account.stage`, `_account.prod`). There is also an `_account.all` group that allows you to switch to all other
   accounts. Make sure your IAM user is in the appropriate group.

Once you take care of the two prerequisites above, you will need two pieces of information to switch to another
account:

1. The ID of the account you wish to switch to. You should get this from whoever administers your AWS accounts.

1. The name of the IAM role in that account you want to assume. Typically, this will be one of the [roles from the
   cross-account-iam-roles module](https://github.com/maxar-infrastructure/module-security/tree/master/modules/cross-account-iam-roles#resources-created)
   
   such as `allow-read-only-access-from-other-accounts` or `allow-full-access-from-other-accounts`.

With these two pieces of data, you should be able to switch accounts in the AWS console or with AWS CLI tools as
explained in the following two sections.




### Switching accounts in the AWS console

Check out the [AWS Switching to a Role (AWS Console)
documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html) for instructions
on how to switch between accounts in the AWS console with a single click.


### Switching with CLI tools (including Terraform)

The official way to assume an IAM role with AWS CLI tools is documented here: [AWS Switching to a Role (AWS Command
Line Interface) documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html). This
process requires quite a few steps, so here are easier ways to do it:

1. [Terragrunt](https://github.com/maxar-infrastructure/terragrunt) has the ability to assume an IAM role before running
   Terraform. That means you can authenticate to any account by:

    1. Authenticate to your Security account (the one where the IAM users are defined) using the normal process, such
       as setting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables for that account.

    1. Call Terragrunt with the `--terragrunt-iam-role` argument or set the `TERRAGRUNT_IAM_ROLE` environment variable.
        For example, to assume the `allow-full-access-from-other-accounts` role in account `1111111111111`:
       `export TERRAGRUNT_IAM_ROLE=arn:aws:iam::1111111111111:role/allow-full-access-from-other-accounts`.

    1. Now you can use all your normal Terragrunt commands: e.g., `terragrunt plan`.

1. If you want to assume an IAM role in another account for some other AWS CLI tool, the easiest way to do it is with
   the [aws-auth script](https://github.com/maxar-infrastructure/module-security/tree/master/modules/aws-auth), which can
   reduce the authentication process to a one-liner. This tool is also useful for authenticating in the CLI when MFA
   is enabled.




## Authenticating

Some best practices around authenticating to your AWS account:

* [Enable MFA](#enable-mfa)
* [Use a password manager](#use-a-password-manager)
* [Don't use the root user](#dont-user-the-root-user)

Note that most of this section comes from the [Gruntwork Security Best Practices
document](https://docs.google.com/document/d/e/2PACX-1vTikva7hXPd2h1SSglJWhlW8W6qhMlZUxl0qQ9rUJ0OX22CQNeM-91w4lStRk9u2zQIn6lPejUbe-dl/pub), so make sure to read through that for more info.

### Enable MFA

Always enable multi-factor authentication (MFA) for your AWS account. That is, in addition to a password, you must
provide a second factor to prove your identity. The best option for AWS is to install [Google
Authenticator](https://support.google.com/accounts/answer/1066447?hl=en) on your phone and use it to generate a one-time
token as your second factor.


### Use a password manager

Never store secrets in plain text. Store your secrets using a secure password manager, such as
[pass](https://www.passwordstore.org/), [OS X Keychain](https://en.wikipedia.org/wiki/Keychain_(software)), or
[KeePass](http://keepass.info/). You can also use cloud-based password managers, such as
[1Password](https://1password.com/) or [LastPass](https://www.lastpass.com/), but be aware that since they have
everyone's passwords, they are inherently much more tempting targets for attackers. That said, any reasonable password
manager is better than none at all!


### Don't use the root user

AWS uses the [Identity and Access Management (IAM)](https://aws.amazon.com/iam/) service to manage users and their
permissions. When you first sign up for an AWS account, you are logged in as the *root user*. This user has permissions
to do everything in the account, so if you compromise these credentials, you’re in deep trouble.

Therefore, right after signing up, you should:

1. Enable MFA on your root account. Note: we strongly recommend making a copy of the MFA secret key. This way, if you
   lose your MFA device (e.g. your iPhone), you don’t lose access to your AWS account. To make the backup, when
   activating MFA, AWS will show you a QR code. Click the "show secret key for manual configuration" link and save that
   key to a secure password manager.

1. Make sure you use a very long and secure password. Never share that password with anyone. If you need to store it
   (as opposed to memorizing it), only store it in a secure password manager.

1. Use the root account to create a separate IAM user for yourself and your team members with more limited IAM
   permissions. You should manage permissions using IAM groups. See the [iam-groups
   module](https://github.com/maxar-infrastructure/module-security/tree/master/modules/iam-groups) for details.

1. Use IAM roles when you need to give limited permissions to tools (for eg, CI servers or EC2 instances).

1. Require all IAM users in your account to use MFA.

1. Never use the root IAM account again.





## Kubernetes RBAC Roles and Helm Authentication

Up to this point we focused on accounts and authentication in AWS. However, with EKS, Kubernetes adds another layer of
accounts and authentication that are tied to, but not exactly the same as, AWS IAM.

In this section, you'll learn about Kubernetes RBAC roles and Helm authentication:

* [RBAC basics](#rbac-basics)
* [Relation to IAM roles](#relation-to-iam-roles)
* [Namespaces and RBAC](#namespaces-and-rbac)
* [Accessing to the cluster](#accessing-the-cluster)
    * [Terragrunt / Terraform](#terragrunt--terraform)
    * [Kubectl](#kubectl)
    * [Helm](#helm)


### RBAC basics

[Role Based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) is a method to regulate
access to resources based on the role that individual users assume in an organization. Kubernetes allows you to define
roles in the system that individual users inherit, and explicitly grant permissions to resources within the system to
those roles. The Control Plane will then honor those permissions when accessing the resources on Kubernetes through
clients such as `kubectl`. When combined with namespaces, you can implement sophisticated control schemes that limit the
access of resources across the roles in your organization.

The RBAC system is managed using `ClusterRole` and `ClusterRoleBinding` resources (or `Role` and `RoleBinding` resources
if restricting to a single namespace). The `ClusterRole` (or `Role`) object defines a role in the Kubernetes system that
has explicit permissions on what it can and cannot do. These roles are then bound to users and groups using the
`ClusterRoleBinding` (or `RoleBinding`) resource. An important thing to note here is that you do not explicitly create
users and groups using RBAC, and instead rely on the authentication system to implicitly create these entities.

You can refer to [Gruntwork's RBAC example
scenarios](https://github.com/maxar-infrastructure/terraform-aws-eks/tree/master/modules/eks-k8s-role-mapping#examples) for use
cases.



### Relation to IAM Roles

EKS manages authentication to Kubernetes based on AWS IAM roles and users. This is done by embedding AWS IAM credentials
(the access key and secret key) into the authentication token used to authenticate to the Kubernetes API. The API server
then forwards this to AWS to validate it, and then reconciles the role / user into an RBAC user and group that is then
used to reconcile authorization rules for the API.

By default all IAM roles and users (except for the role / user that deployed the cluster) has no RBAC user or groups
associated with it. This automatically translates the role / user into an anonymous user on the cluster, who by default
has no permissions. In order to allow access to the cluster, you need to explicitly bind the IAM role / user to an RBAC
entity, and then bind `Roles` or `ClusterRoles` that explicitly grants permissions to perform actions on the cluster.
This mapping is handled by the [eks-k8s-role-mapping
module](https://github.com/maxar-infrastructure/terraform-aws-eks/tree/master/modules/eks-k8s-role-mapping), used under the hood
in the [eks-cluster infrastructure module](https://github.com/maxar-infrastructure/infrastructure-modules-multi-account-acme/tree/master/services/eks-cluster).

You can read more about the relationship between IAM roles and RBAC roles in EKS in [the official
documentation](https://docs.aws.amazon.com/eks/latest/userguide/managing-auth.html).



### Namespaces and RBAC

[Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) are Kubernetes resources
that creates virtual partition boundaries in your cluster. The resources in each `Namespace` are isolated from other
`Namespaces`, and can only interact with them through `Service` endpoints, unless explicit permissions are granted. This
allows you to divide the cluster between multiple users in a way that prevents them from seeing each others' resources,
allowing you to share clusters while protecting sensitive information.

RBAC is critical in achieving isolation of `Namespaces`. The RBAC permissions can be restricted by `Namespace`. This
allows you to bind permissions to entities such that they can only perform certain actions on resources within a
particular `Namespace`.

Refer to the [eks-k8s-role-mapping module
docs](https://github.com/maxar-infrastructure/terraform-aws-eks/tree/master/modules/eks-k8s-role-mapping#restricting-by-namespace)
for an example on using RBAC to restrict actions to a particular `Namespace`.

Every EKS cluster comes with two default `Namespaces`:

- `kube-system`: This `Namespace` holds admin and cluster level resources. Only cluster administrators ("superusers")
  should have access to this `Namespace`.
- `default`: This is the default `Namespace` that is used for API calls that don't specify a particular `Namespace`.
  This should primarily be used for development and experimentation purposes.

Additionally, in the Reference Architecture, we create another `Namespace`: `applications`. This `Namespace` is used to
house the deployed sample applications and its associated resources.

Most Kubernetes tools will let you set the `Namespace` as CLI args. For example, `kubectl` supports a `-n` parameter for
specifying which `Namespace` you intend to run the command against. `kubectl` additionally supports overriding the
default `Namespace` for your commands by binding a `Namespace` to your authentication context.



### Accessing the cluster

As mentioned in [Relation to IAM Roles](#relation-to-iam-roles), EKS proxies Kubernetes authentication through AWS IAM
credentials. This means that you need to be authenticated to AWS first in order to authenticate to Kubernetes. Refer to
[the previous section on AWS authentication](#authenticating) for information on how to authenticate to AWS.

There are three main ways to interact with Kubernetes in the Reference Architecture:

* [Using Terragrunt / Terraform](#terragrunt--terraform)
* [Using kubectl](#kubectl)
* [Using Helm](#helm)


#### Terragrunt / Terraform

When deploying Kubernetes resources using Terragrunt / Terraform, all the authentication is handled inside of Terraform
using a combination of EKS data sources and provider logic. What this means is that you don't have to worry about
explicitly authenticating to Kubernetes when going through Terraform, as long as you are authenticating to an IAM role
that has a valid mapping to an RBAC entity in the cluster.


#### Kubectl

Most manual operations in Kubernetes are handled through [the kubectl command line
utility](https://kubernetes.io/docs/reference/kubectl/overview/). `kubectl` requires an explicit authentication
configuration to access the cluster.

You can use `kubergrunt` to configure your local `kubectl` client to authenticate against a deployed EKS cluster. After
authenticating to AWS, run:

```bash
kubergrunt eks configure --eks-cluster-arn $EKS_CLUSTER_ARN
```

This will add a new entry to your `kubectl` config file (defaults to `$HOME/.kube/config`) with the logic for
authenticating to EKS, registering it under the context name `$EKS_CLUSTER_ARN`. You can modify the name of the context
using the `--kubectl-context-name` CLI arg.

You can verify the setup by running:

```bash
kubectl cluster-info
```

This will report information about the Kubernetes endpoints for the cluster only if you are authorized to access to the
cluster. Note that you will need to be authenticated to AWS for `kubectl` to successfully authenticate to the cluster.

If you have multiple clusters, you can switch the `kubectl` context using the `use` command. For example, to switch the
current context to the `dev` EKS cluster from the `prod` cluster and back:

```bash
kubectl use arn:aws:eks:us-east-1:$DEV_ACCOUNT_ID:cluster/eks-dev
kubectl cluster-info  # Should target the dev EKS cluster
kubectl use arn:aws:eks:us-east-1:$PROD_ACCOUNT_ID:cluster/eks-prod
kubectl cluster-info  # Should target the prod EKS cluster
```

#### Helm

Helm relies on the same authentication configuration file as `kubectl`. This means that if you setup authentication for
`kubectl`, `helm` will be able to use the same authentication configuration to access the cluster. Once you setup
`kubectl`, try accessing the `helm` resources by using the `ls` command:

```bash
helm ls
```




## Next steps

Now that you know how to authenticate, you may want to take a look through this list of [Gruntwork
Tools](10-gruntwork-tools.md).
