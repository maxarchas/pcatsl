# Running An App in the Dev Environment

Now that you have an idea of [what the architecture looks like](01-architecture-overview.md), [what's
deployed](02-whats-deployed.md), [security compliance](03-security-compliance-compatibility.md), and [how the code is
organized](04-how-code-is-organized.md), it's time to start running some of that code on your own computer!

Here's what we'll cover:

* [Prerequisites](#prerequisites)
* [Checkout the code](#checkout-the-code)
* [Run the app](#run-the-app)
* [Make a service call](#make-a-service-call)
* [Change the code](#change-the-code)
* [Update the application configuration](#update-the-application-configuration)
* [Encrypt a secret](#encrypt-a-secret)
* [Apply schema migrations](#apply-schema-migrations)
* [Commit your changes](#commit-your-changes)




## Prerequisites

You will need to install the following software on your computer:

* [Git](https://git-scm.com/): Used for version control.
* [Docker](http://docker.com/): Used to package apps so they run the same way in all environments, including your dev 
  environment.
* [Terraform](https://www.terraform.io/): Used to provision and manage infrastructure as code.
* [Terragrunt](https://github.com/maxar-infrastructure/terragrunt): A thin wrapper for Terraform that provides extra tools for 
  working with multiple Terraform modules.
* [Packer](https://www.packer.io/): Used to package apps as Amazon Machine Images.
* [GruntKMS](https://github.com/maxar-infrastructure/gruntkms): Used to encrypt and decrypt secrets.




## Checkout the code

You will need to checkout the code for your app(s) using Git. For this tutorial, we are going to checkout 
[sample-app-frontend-multi-account-acme](https://github.com/maxar-infrastructure/sample-app-frontend-multi-account-acme), which is a sample app that's handy for 
demonstrating all the key concepts in this tutorial. 

To check this app out onto your computer, run:

```bash
git clone git@github.com:maxar-infrastructure/sample-app-frontend-multi-account-acme.git
```

Note that sample-app-frontend-multi-account-acme depends on another sample app called [sample-app-backend-multi-account-acme](https://github.com/maxar-infrastructure/sample-app-backend-multi-account-acme), 
so you may want to checkout that app too:

```bash
git clone git@github.com:maxar-infrastructure/sample-app-backend-multi-account-acme.git
```




## Run the app

sample-app-frontend-multi-account-acme is packaged as a [Docker](http://docker.com/) container so that it runs the same way in all 
environments, including on your computer. Moreover, we've used [Docker Compose](https://docs.docker.com/compose/) to
configure all the Docker containers you need to run your entire tech stack (i.e., all apps, databases, etc) in the
`docker-compose.yml` file, so you can fire everything up with a single command:

```bash
cd sample-app-frontend-multi-account-acme
docker-compose up
```

Your entire stack will boot up in a few seconds and you should be able to test it by going to 
http://localhost:3000/sample-app-frontend-multi-account-acme. 

The app that's running is a simple [Node.js](https://nodejs.org/en/) app, but the ideas demonstrated work more or less
the same way in any language. Take a look at `app/index.js` to see the code. You should also see other endpoints in
that file that you can try.




## Make a service call

One of the other endpoints you can try is http://localhost:3000/sample-app-frontend-multi-account-acme/service.
This demonstrates how sample-app-frontend-multi-account-acme can make a service call to sample-app-backend-multi-account-acme. How does this work? 

If you dig through the code in `app/server.js`, you'll see that sample-app-frontend-multi-account-acme is getting the IP address of 
sample-app-backend-multi-account-acme from an environment variable called `BACKEND_URL` and falling back to the value `backend` if that
environment variable is not set. Here's how this works:

* In dev, [Docker Compose Networking](https://docs.docker.com/compose/networking/) sets up a single network where each
  service `xxx` is accessible at the hostname `xxx`. Since our service is called `backend`, it is accessible at
  `http(s)://backend`. 
  
* In other environments (e.g. stage, prod) we configure Terraform to set the `BACKEND_URL` environment variable for 
  your Docker containers, except we point the variable to an internal Application Load Balancer (see 
  [Architecture overview](01-architecture-overview.md)), which is configured to route traffic to sample-app-backend-multi-account-acme. 

We use a similar approach to allow the app to talk to all of its other dependencies too (e.g., the database, cache, 
etc), with slightly different service names and environment variables for each one.




## Change the code

Make a change to the app code, such as modifying `app/index.js` or `app/index.html`.
Refresh the page in your browser and you should see your changes immediately! Here's how that works:

* In `docker-compose.yml`, we configure Docker to [mount](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume) 
  the code from your host OS into the Docker container (look for the `volumes` settings in `docker-compose.yml`). That
  way, every time you make a change on your host OS, it's reflected immediately in the Docker container.
  
* The Docker container uses [nodemon](https://github.com/remy/nodemon) in dev mode, so the Node app restarts 
  automatically with every change. 
  
This setup allows you to iterate rapidly!




## Update the application configuration

sample-app-frontend-multi-account-acme stores most of its configuration settings in files. The advantage of this is that the files are 
checked into version control (so you have a history of config changes) and are versioned and deployed with the app code 
itself (so you don't get a mismatch between app and config). 

* The files live in the `config` directory. 

* The names use the format `example-config-<environment>.json`, where `environment` is an environment name, such as 
  development, stage, or prod. Note that the same basic config approach shown here works with any file format and 
  naming convention; we only use JSON because it's easy to use with the sample Node.js app.

* In `app/server.js`, the app loads the proper config file for the current environment based on the environment 
  variable `VPC_NAME`.
  
* In dev, the `VPC_NAME` environment variable is configured in `docker-compose.yml`.

* In other environments (e.g., stage, prod) the `VPC_NAME` environment variable is set by Terraform.




## Encrypt a secret

Occasionally, you may need to encrypt some secret data. For example, you may want to store the password to your 
database in your app's configuration. Storing secrets in plain text anywhere, including version control, is a major 
security risk and should be avoided (see [Gruntwork Security Best Practices](https://docs.google.com/document/d/e/2PACX-1vTikva7hXPd2h1SSglJWhlW8W6qhMlZUxl0qQ9rUJ0OX22CQNeM-91w4lStRk9u2zQIn6lPejUbe-dl/pub)
for more info). A better way to handle this is to encrypt the secrets before putting them in version control and to 
have your app decrypt those secrets before it boots.
  
Managing encryption keys securely is very tricky, so we strongly recommend using [Amazon's Key Management Service 
(KMS)](https://aws.amazon.com/kms/): 

1. Create "master key" in KMS using the [kms-master-key 
   module](https://github.com/maxar-infrastructure/module-security/tree/master/modules/kms-master-key). Note that we've already 
   created one master key in each environment, so for most use cases, you should use those and not create any new ones. 
   You can see all available master keys in the [Encryption Keys page in 
   IAM](https://console.aws.amazon.com/iam/home?region=us-east-1#/encryptionKeys/us-east-1). 

1. Use the master key, along with [gruntkms](https://github.com/maxar-infrastructure/gruntkms), to encrypt and decrypt secrets 
   with a single CLI command.
 
For example, you could run `gruntkms` on your computer to encrypt a database password:
 
```bash
# A developer encrypts a plaintext secret
$ echo "super secret database password" | gruntkms encrypt --key-id "alias/cmk-stage" --aws-region "us-east-1"
kmscrypt::AQICAHhQYFj4xrlpRdnui/MrOlrIt+gSSrFxZay4ZMDMofceSwEXSzGkmBBWbG6==
```
 
You can now safely check the `kmscrypt::...` ciphertext into version control.

You can then give your apps access to the same KMS key via IAM permissions and configure your apps to decrypt the 
ciphertext using `gruntkms` just before booting:

```bash
# An app decrypts the ciphertext before booting
echo "kmscrypt::AQICAHhQYFj4xrlpRdnui/MrOlrIt+gSSrFxZay4ZMDMofceSwEXSzGkmBBWbG6==" | gruntkms decrypt --aws-region "us-east-1"
"super secret database password" 
```

Make sure to read through the [gruntkms docs](https://github.com/maxar-infrastructure/gruntkms) to learn how how the `kmscrypt::` 
prefix works and how to decrypt all secrets in a config file in a single command (see `bin/run-app.sh` in the sample 
apps for an example).






## Apply schema migrations

sample-app-backend-multi-account-acme contains example code of how to talk to a relational database. It also contains an example of how
to apply schema migrations to your database before the app boots. The idea is to version and package the schema 
migration code with the app code so that whenever you deploy a new version of the app, it always ensures the schema it
depends on is in place before booting.

Under the hood, the example code manages the schema migrations using simple `.sql` files (see the `sql` folder) and 
uses [Flyway](https://flywaydb.org/) to apply those migrations (see `bin/run-app.sh`). The same basic approach should
work with any other schema migration tool (e.g., [Luiqibase](http://www.liquibase.org/), 
[ActiveRecord](http://edgeguides.rubyonrails.org/active_record_migrations.html)) as long as that tool obtains a lock 
before applying schema changes (to ensure you only apply the schema changes once even if multiple copies of the app
boot up at the same time).




## Commit your changes

If you've made any changes to the code during this tutorial, it's time to commit them back to Git!

```bash
git add <files_you_modified>
git commit -m "<commit message>"
git push origin master
```


## Next steps

Now that you've committed some code, it's time to learn how the automated [Build, test, and deployment
(CI/CD)](06-ci-cd.md) process works.
