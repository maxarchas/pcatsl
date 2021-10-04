<!--
:type: service
:name: Multi-account AWS Reference Architecture
:description: End-to-end tech stack designed to deploy into a multiple AWS account. Includes VPCs, EKS, ALBs, CI / CD, auth, monitoring, alerting, VPN, DNS, and more.
:icon: /_docs/_images/ref-arch-icon.png
:category: Reference Architecture
:cloud: aws
:tags: tech-stack, end-to-end
:license: gruntwork
:built-with: terraform, bash, python, go
-->

# Live Infrastructure

This repository contains code to deploy infrastructure across all live environments for Acme Multi Account in AWS. The
code deploys modules from the 
[infrastructure-modules-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-modules-multi-account-acme) repository. This
code was built on top of the [Gruntwork Reference Architecture](https://gruntwork.io/reference-architecture/). 

![Reference Architecture](_docs/_images/ref-arch-full.png?raw=true)




## Features

- End-to-end tech stack for AWS.
- 100% defined and managed as code using tools such as Terraform, Docker, and Packer.
- Built on top of the reusable, battle-tested, commercially supported code from the [Gruntwork Infrastructure as Code 
  Library](https://gruntwork.io/infrastructure-as-code-library/). 
- Deployed into your AWS accounts in about 1 day.
- Customized to your needs:  
    - Run containerized services using Kubernetes or ECS.
    - Run VMs on EC2 Instances and Auto Scaling Groups.
    - Use PostgreSQL, MySQL, SQL Server, or other relational database.
    - Use Redis or Memcached as a distributed cache.
    - Use other data stores such as Kafka, ZooKeeper, ELK, SQS, Kinesis, and MongoDB.
    - Optionally enable end-to-end encryption (e.g., as part of HIPAA, PCI, or other compliance programs).
    - Configure a CI / CD pipeline in CircleCI, Travis CI, or Jenkins.
    - Access the network via a Bastion Host or OpenVPN server.
    - Use KMS for secrets management.
    - Store static content in S3, with CloudFront as a CDN.
    - Build serverless apps with AWS Lambda and API Gateway.
    - Configure monitoring, alerting, and log aggregation in CloudWatch.
    - And much more!




## Learn

### Core concepts

* [Reference Architecture Walkthrough Documentation](/_docs): Comprehensive documentation that walks through all 
  aspects of this architecture, including what's deployed, how the code is organized, how to run the code in dev,
  how the CI / CD pipeline works, how to access metrics and logs, how to connect via VPN and SSH, and much more. 
* [Gruntwork Reference Architecture Training Course](https://training.gruntwork.io/p/reference-architecture-walkthrough):
  A video course that walks through you what the Reference Architecture is and how to use it.  
* [How to Build an End to End Production-Grade Architecture on AWS](https://blog.gruntwork.io/how-to-build-an-end-to-end-production-grade-architecture-on-aws-part-1-eae8eeb41fec):
  A blog post series that discusses the basic principles behind the Reference Architecture.
* [How to use the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/):
  The Reference Architecture is built on top of the [Gruntwork Infrastructure as Code 
  Library](https://gruntwork.io/infrastructure-as-code-library/). Check out this guide to learn what the library is and
  how to use it.
* [Gruntwork Production Deployment Guides](https://gruntwork.io/guides/): Step-by-step guides that show you how to go 
  to production on top of AWS.

### Repo organization

* [How the code is organized](/_docs/04-how-code-is-organized.md): An overview of how the code in this repo and all 
  other Reference Architecture repos is organized. 
* [What's deployed](/_docs/02-whats-deployed.md): An overview of what's deployed in your AWS accounts.




## Deploy

### Deploy updates

If you want to deploy updates to this infrastructure, check out the following resources:

* [Deploying app changes](/_docs/06-ci-cd.md#deploying-app-changes): Instructions on how to deploy changes to an app,
  such as a Java/Ruby/Python web service packaged with Docker or Packer.
* [Deploying infrastructure changes](/_docs/06-ci-cd.md#deploying-infrastructure-changes): Instructions on how to 
  deploy changes to infrastructure code, such as Terraform modules that configure your VPCs, databases, DNS settings, 
  etc.
* [Adding New Environments, Regions, and Accounts](/_docs/15-adding-new-environments-regions-and-accounts.md): 
  Instructions on how to add a new environment, region, or account to your Reference Architecture.

### Deploy from scratch

If you want to deploy this infrastructure from scratch, check out the following resources:

* [Deploying a new Docker service from scratch](/_docs/11-deploying-a-docker-service.md): Instructions on how to 
  Dockerize a new app and deploy it into the Reference Architecture.
* [Deploying the Reference Architecture from scratch](/_docs/13-deploying-the-reference-architecture-from-scratch.md):
  Instructions on how to deploy the Reference Architecture from scratch.
* [Undeploying the Reference Architecture](/_docs/14-undeploying-the-reference-architecture.md): Instructions on how to 
  undeploy the Reference Architecture completely.



## Manage

### Day-to-day operations

* [How to authenticate to AWS](_docs/09-accounts-and-auth.md)
* [How to connect via VPN and/or SSH](/_docs/08-ssh-vpn.md)
* [How to view metrics, logs, and alerts](/_docs/07-monitoring-alerting-logging.md)
* [Useful tools](/_docs/10-gruntwork-tools.md)

### Major changes

* [How to migrate to the Reference Architecture](/_docs/12-migration.md)




## Support

If you need help with this repo or anything else related to infrastructure or DevOps, Gruntwork offers 
[Commercial Support](https://gruntwork.io/support/) via Slack, email, and phone/video. If you're already a Gruntwork 
customer, hop on Slack and ask away! If not, [subscribe now](https://www.gruntwork.io/pricing/). If you're not sure, 
feel free to email us at [support@gruntwork.io](mailto:support@gruntwork.io).
