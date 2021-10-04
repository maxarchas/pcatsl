# Adding New Environments, Regions, and Accounts

**NOTE: This doc assumes you have read through [Deploying the Reference Architecture from scratch](./13-deploying-the-reference-architecture-from-scratch.md). Many concepts would not make sense until you have read through that document!**

Up until now we have focused on the initial code that Gruntwork has provided in the Reference Architecture. However,
this Reference Architecture is meant to be used in production and will evolve over time. This document is meant to act
as a guide to lay out the steps necessary to evolve the Reference Architecture by taking a look at a few common
scenarios:

- [Adding a new component or service](#adding-a-new-component)
- [Adding a new environment, region, or account](#adding-a-new-environment-region-or-account)


## Adding a new component

One of the most common things you might want to do with the Reference Architecture is to extend it with additional
services or data stores (an *infrastructure component*). Here are the rough steps for adding a new component to the
Reference Architecture:

1. [Plan the necessary work](#plan-the-necessary-work)
1. [Add a new library module to deploy the infrastructure for the component (if necessary)](#add-a-new-library-module-to-deploy-the-infrastructure-for-the-component-if-necessary)
1. [Add a new infrastructure module and live config to deploy the
   component](#add-a-new-infrastructure-module-and-live-config-to-deploy-the-component)

### Plan the necessary work

The first step in adding a new component to the Reference Architecture is actually to decide what you will need to
deploy the component. For example, suppose you want to add a new data service (e.g Kafka). Some questions that you
should be asking yourself are:

- Is there a managed service offering that simplifies the deployment?
- Do I want to run the service using Docker or VMs?
- Does the service have any dependencies such as S3?
- Do I need any IAM roles for the service?

You can see the full range of questions in our [Production Grade Infrastructure
Checklist](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/#production_grade_infra_checklist).

Once you have a sense of the components that should be deployed, the next thing to figure out is what modules you will
need to build in order to maintain all that code. You should start by taking a look at [the Gruntwork catalog of
infrastructure modules](https://gruntwork.io/infrastructure-as-code-library/) and seeing if Gruntwork has a library
module for the components that you need. You can also slack us using your private channel (if you are on our
Professional Support plan), or the community channel to get help deciding which library modules are relevant for your
component. Alternatively, you can email [support@gruntwork.io](mailto:support@gruntwork.io).

You should come out of this step with an itemized list of the modules that you plan on using, and any modules that you
will need to build from scratch. You will also want to make sure Terraform has resources available for managing the
components you wish to use. Be sure to familiarize yourself with existing modules and resources if any of the
infrastructure components you plan on deploying is new to you!

### Add a new library module to deploy the infrastructure for the component (if necessary)

If you find out that Gruntwork does not have a module for the infrastructure components you wish to deploy, you will
need to build the relevant modules from scratch. You can either build the relevant module directly in
[infrastructure-modules-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-modules-multi-account-acme) where all the
blueprint modules exist, or have a dedicated repository to build out the module. The advantage of using a dedicated
repository is that you can write targetted "unit" tests for the module to ensure correctness by using [the Terratest
framework](https://github.com/maxar-infrastructure/terratest), that run faster than testing the whole component being launched
as a part of the `infrastructure-modules` structure. This may make it easier for you to test a range of input variables
to the module.

You also have the option to [contribute this code back to the Gruntwork
library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/#contributing-to-the-gruntwork-infrastructure-as-code-library).
The advantage of contributing your code is that you can rely on Gruntwork to manage the code going forward, including
performing updates to newer versions of terraform, implementing new features, or fix bugs that are filed against it. It
is also a good way to get it battle tested across multiple different scenarios from the Gruntwork community, leading to
a better module overall.

### Add a new infrastructure module and live config to deploy the component

Once you have a library module for your component, the next step is to integrate it into your architecture. This
involves adding a wrapper module in [infrastructure-modules-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-modules-multi-account-acme)
that can be deployed using your live config in [infrastructure-live-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-live-multi-account-acme).

You can find detailed instructions to integrate the module in the [Using Terraform Modules section of the Gruntwork
foundations guide: How to use the Gruntwork Infrastructure as Code
Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/#using_terraform_modules).


## Adding a new environment, region, or account

The steps for adding a new environment, region, or account to the Reference Architecture are largely similar. At its
core, each of these scenarios involves deploying a new stack, comprising a logical group of components. The key difference is the
magnitude of the stack: environments typically start at the VPC and include everything inside it, while a region might
be multiple VPCs, and finally accounts would include multiple regions as well as global resources like IAM. Nevertheless
at the end of the day, each of these scenarios are deploying a group of components where you should already have most of
the code ready. As such, the steps for each of these scenarios are largely the same:

1. [Plan the necessary work](#plan-the-necessary-work)
1. [Add necessary module components](#add-necessary-module-components)
1. [Copy or add the live config](#copy-or-add-the-live-config)
1. [Deploy](#deploy)

### Plan the necessary work

Before attempting to add a new environment, region, or account, you should have a sense of all the steps required to
stand up the infrastructure from scratch. You should know things like what secrets you will need to generate (e.g
passwords, certificates, etc), whether or not you need to purchase resources that are difficult to manage with Terraform
(e.g DNS domains), or whether or not you have all the code to deploy the entire stack (e.g if you are provisioning a new
environment with a completely different stack structure). You should also familiarize yourself with the dependencies of
each component in the stack, and the rough order of operations. You can use the guide [Deploying the Reference
Architecture from scratch](./13-deploying-the-reference-architecture-from-scratch.md) as a reference for finding out the
rough order of operations.

You should take this opportunity to write out a playbook of the deployment order of the components in the stack you are
about to roll out. This document will come in handy when you are ready to start provisioning the infrastructure.

### Add necessary module components

Once you have a sense of what components are included in the stack, you should decide if you need to add any new
modules to [infrastructure-modules-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-modules-multi-account-acme). Follow
the guide [Adding a new component](#adding-a-new-component) to add the necessary module code for deploying the stack.

### Copy or add the live config

Once you have all the module code ready, it is time to start setting up the live config to deploy your infrastructure.
If you are replicating an existing stack, the easiest approach is to copy paste the directory tree for the stack. For
example, suppose you had the following directory tree:

```
.
└── dev
    └── us-east-2
        ├── dev
        │   ├── eks
        │   ├── elasticache
        │   ├── rds
        │   └── vpc
        └── mgmt
            ├── vpc
            └── vpn
```

The first level is the account, followed by the region, followed by environments, and finally components at the bottom
level.

If you wanted to replicate the `dev` environment into a new environment `preview` in the same region, you would copy
paste the `dev` folder at that level:

```
.
└── dev
    └── us-east-2
        ├── preview
        │   ├── eks
        │   ├── elasticache
        │   ├── rds
        │   └── vpc
        ├── dev
        │   ├── eks
        │   ├── elasticache
        │   ├── rds
        │   └── vpc
        └── mgmt
            ├── vpc
            └── vpn

```

Or if you wanted to deploy to a new region `eu-west-1`, you would copy the whole region tree:

```
.
└── dev
    ├── eu-west-1
    │   ├── dev
    │   │   ├── eks
    │   │   ├── elasticache
    │   │   ├── rds
    │   │   └── vpc
    │   └── mgmt
    │       ├── vpc
    │       └── vpn
    │
    └── us-east-2
        ├── dev
        │   ├── eks
        │   ├── elasticache
        │   ├── rds
        │   └── vpc
        └── mgmt
            ├── vpc
            └── vpn
```

The key thing to note here is that references to dependencies in the terragrunt folder structure are made using relative
paths. For example, the `vpc` in the `dev` environment will setup peering with the `vpc` in the `mgmt` environment of
the same region. This reference is made by using the relative path from that `vpc` folder to the `mgmt` environment
`vpc` folder (`../mgmt/vpc`). When you copy paste to a new environment, this path doesn't change!

Once you copy paste the new stack, you will want to rename the inputs to ensure correctness with the new environment.
You will want to take a closer look at variables such as:

- **Names**: Some global resources require unique names, such as S3 buckets and IAM roles and groups. Although these are
  namespaced using variables, you can't reuse the copied values since they have already been deployed in your other
  stack. Make sure you update any variables that set names and name prefixes for the components.
- **Secrets**: You will most likely want to use different passwords and certificates for the new components. If the
  secrets are encrypted, you might also want a new KMS key to encrypt the secrets. You will want to make sure you update
  them.  Variable files: In terragrunt, it is common to store and source common variables in a yaml file in the tree.
  For example, you might have the following folder structure:

    ```
    .
    └── dev
        ├── account.yml
        └── us-east-2
            ├── dev
            │   └── env.yml
            └── region.yml
    ```

  Each of these yaml files, `account.yml`, `region.yml`, and `env.yml` will contain contents that set common variables
  for that level. For example, `region.yml` might contain an entry to set the `aws_region` input var to the region.
  These are then sourced and merged into the `inputs` list to configure the variables when deploying. You will want to
  make sure any variable files you copy are updated to point to the correct value for the new components in that tree.
- **Network addresses**: Any Route53 domains and CIDR blocks should be updated to ensure they don't collide with existing
  infrastructure.
- **Hardcoded region specific resources**: AMIs can only be used within the region that they exist. This means that if
  you are adding a new region or account, you will need to build new AMIs and update the AMI inputs. This is also true
  for EC2 key pairs, KMS keys, SNS topics, and myriad other services.

You should also take this moment to add any live config files for new components to the stack that you will need.

### Deploy

Once you have the live config for your entire stack, it is time to deploy the stack! In most cases, this will be a
`terragrunt apply-all` at the top level of the stack. Sometimes, this will involve prerequisite steps like building new
AMIs and setting up new domains.

For best results in deploying the infrastructure, you will want to follow the playbook that you wrote out in [the
planning step](#plan-the-necessary-work).

**Note on adding a new account**: When adding a new account, you will most likely not have the state bucket setup for
the account. This can be problematic if you run a `terragrunt apply-all` for the first time, because all the modules
will prompt you if you want to create the state bucket, which breaks when there are multiple modules happening at the
same time. To avoid this, you can pass in `--terragrunt-non-interactive` to `apply-all` which will skip the prompt and
automatically create the bucket for you.
