# What's deployed?

Now that you've read through the basic [Architecture overview](01-architecture-overview.md), it's time to look at what
is deployed and how to access it. This document contains a few links and pointers to particularly useful resources in
the following environments:


* [Prod](#prod-environment)
* [Stage](#stage-environment)
* [Mgmt](#mgmt-environment)




## Prod environment

* Sample frontend app: https://www.gruntwork.io/sample-app-frontend-multi-account-acme
* Sample backend app: http://services.acme-multi-account.aws/sample-app-backend-multi-account-acme (only accessible from within the VPC, see [SSH and VPN](08-ssh-vpn.md))
* Static content: https://static.gruntwork.io




## Stage environment

* Sample frontend app: https://www.gruntwork.io/sample-app-frontend-multi-account-acme
* Sample backend app: http://services.acme-multi-account.aws/sample-app-backend-multi-account-acme (only accessible from within the VPC, see [SSH and VPN](08-ssh-vpn.md))
* Static content: https://static.gruntwork.io



## Mgmt environment

* OpenVPN server (only accessible from Acme Multi Account's office IP addresses, see [SSH and VPN](08-ssh-vpn.md)):
    * dev: `vpn.gruntwork.io`
    * prod: `vpn.gruntwork.io`
    * shared-services: `vpn.gruntwork.io`
    * stage: `vpn.gruntwork.io`
* Jenkins: https://jenkins.gruntwork.io (only accessible  when connected via VPN, see [Build, tests, and deployment (CI/CD)](06-ci-cd.md))






## Next steps

Next up, we'll go through [Security compliance compatibility](03-security-compliance-compatibility.md).
