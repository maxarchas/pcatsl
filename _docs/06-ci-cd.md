# Build, tests, and deployment (CI/CD)

In the previous section, you [ran the app in the dev environment](05-dev-environment.md), made some changes to the code,
and committed those changes to Git. Now it's time to see how you deploy your changes to AWS.
* [Deploying app changes](#deploying-app-changes): how to deploy changes to application code, such as a Ruby, Python,
  or Java web service packaged with Packer or Docker.
* [Deploying infrastructure changes](#deploying-infrastructure-changes): how to deploy changes to infrastructure code,
  such as Terraform modules that configure your VPCs, databases, DNS settings, etc. 





## Deploying app changes

Changes to your apps are deployed via an automated Continuous Integration (CI) and Continuous Delivery (CD) pipeline:

* [Trigger a build](#trigger-a-build)
* [Build and test the code](#build-and-test-the-code)
* [Package the code](#package-the-code)
* [Deploy the code](#deploy-the-code)

### Trigger a build

* We have configured Jenkins to poll your Git repos on a regular basis. 

* We don't use webhooks because major security vulnerabilities are found in Jenkins all the time, so we do not 
  want it to be accessible from the public Internet, at all. 

* Every time there is a new commit, it triggers a new build in Jenkins. Note that new tags, by themselves, do NOT 
  trigger a build in Jenkins (it's not supported by the Git Plugin).

* You can trigger a build manually by going to the build page and clicking "Build".

* We are using [Jenkins Pipeline](https://jenkins.io/doc/book/pipeline/) so that the build can be defined as code, in 
  each app repo using a `Jenkinsfile`.

### Build and test the code

* Each Jenkins job will build and test your code. See the "Build" and "Test" stages of the Jenkins job for the specific 
  steps it executes.
 
* If any of the build steps fails, the entire build will fail. You can configure the "failure" section at the bottom
  of the `Jenkinsfile` to notify you of build failures via email.

### Package the code

We package the code as follows:

* Build a new Docker image for the app
* Tag the image with the Git revision (the sha1 hash) of the commit that triggered the build. This makes it easy to 
  track Docker images back to the commits they contain.
* Push the image to [Amazon ECR](https://aws.amazon.com/ecr/) 
* You can now deploy this new Docker image

### Deploy the code

* Commits to the `stage` branch are automatically deployed to the stage environment.
* Commits to the `prod` branch are automatically deployed to the `prod` environment.

The typical workflow is to commit all your changes to `master` and to periodically merge master into `stage` or `prod`
to kick off deployments. For example, to deploy what's in `master` to `stage`, you would do the following:

```bash
git checkout stage
git merge master
git push origin stage
```  

The automatic deployment works as follows:

1. Git clone the [infrastructure-live-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-live-multi-account-acme) repo.
1. Update the `version` property in the service's `terragrunt.hcl` file to the new Docker image tag.
1. `git commit` and `git push` the changes to the `infrastructure-live-multi-account-acme` repo.
1. Run `terragrunt apply` on the Terraform code to deploy the changes.






## Deploying infrastructure changes 

Deploying app changes is fairly easy, as all app deployments are roughly the same, and the cost of an error is fairly 
small. Deploying arbitrary infrastructure changes is more complicated. Due to the complexity and risks involved (e.g.,
an apply deployment going wrong usually does little damage, whereas an infrastructure deployment going wrong could, for
example, delete a database!), we do not have a fully automated CI/CD pipeline for deploying infrastructure changes 
(note: Gruntwork is currently working on it; email [support@gruntwork.io](mailto:support@gruntwork.io) for details), so 
here's the process you should use:

* [Check out the infrastructure repos](#check-out-the-infrastructure-repos)
* [Update the code](#update-the-code)
* [Test your changes in a sandbox environment](#test-your-changes-in-a-sandbox-environment)
* [Submit a pull request](#submit-a-pull-request)
* [Merge in your changes](#merge-in-your-changes)
* [Release a new version](#release-a-new-version)
* [Promote the new version to prod](#promote-the-new-version-to-prod)


### Check out the infrastructure repos

All of the infrastructure code lives in the [infrastructure-modules-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-modules-multi-account-acme)
and [infrastructure-live-multi-account-acme](https://github.com/maxar-infrastructure/infrastructure-live-multi-account-acme) repos (see
[How the code is organized](04-how-code-is-organized.md)).

```bash
git clone git@github.com:maxar-infrastructure/infrastructure-modules-multi-account-acme.git
git clone git@github.com:maxar-infrastructure/infrastructure-live-multi-account-acme.git
```


### Update the code

Make the appropriate changes in either infrastructure-modules-multi-account-acme or infrastructure-live-multi-account-acme. 

* If you want to change some settings for an existing module in an environment, make those changes in the 
  `terragrunt.hcl` files in infrastructure-live-multi-account-acme. 
  
* If you want to change how the underlying modules work or add a new module, make those changes in 
  infrastructure-modules-multi-account-acme. Note that after those changes are committed, you'll need to release a new 
  version of infrastructure-modules-multi-account-acme and update infrastructure-live-multi-account-acme to use that new version
  (both of these steps are described below).    


### Test your changes in a sandbox environment

Every company should have a "sandbox" environment where developers can make Terraform changes without:
 
1. Having to commit those changes to version control.
1. Having to worry that if they break something, it will cause problems for the rest of the team.

While the company is small, a single shared sandbox environment is usually enough. As you grow bigger, you may need 
more to avoid conflicts. The gold standard is to have each developer spin up their own completely isolated environment 
for testing and to tear it down when they are done. Since all of your infrastructure is defined as code, you should be 
able to automate this process!

Once you've figured out where you are going to test, to apply your changes, do the following:

1. Install [Terragrunt](https://github.com/maxar-infrastructure/terragrunt). We use Terragrunt to keep the Terraform code as 
   DRY as possible, so you'll need Terragrunt to make changes. See [Keep your Terraform code 
   DRY](https://github.com/maxar-infrastructure/terragrunt#keep-your-terraform-code-dry) and [Keep your remote state 
   configuration DRY](https://github.com/maxar-infrastructure/terragrunt#keep-your-remote-state-configuration-dry) for 
   background info on how we're taking advantage of Terragrunt.

1. Configure your AWS credentials as [environment variables](http://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html).

1. For some modules, you will also need to install [kubergrunt](https://github.com/maxar-infrastructure/kubergrunt) and
   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
   `kubergrunt` is a collection of scripts packaged as a Go binary that provides certain functionality to make it easier
   to work with Kubernetes and EKS. `kubectl` is a comprehensive CLI for interacting with Kubernetes. You can check out
   the README for any infrastructure code to see if it requires them.

1. Any modules that deploy applications to EKS will also need access to Helm. You can use the `kubergrunt helm
   configure` command to setup access on your machine. See the relevant section in [section 8 "Accounts and Auth" of
   this document](./09-accounts-and-auth.md#helm) for more info. You can also look at the [command
   documentation](https://github.com/maxar-infrastructure/kubergrunt#helm-configure) for more details on the command itself.

1. Go into the appropriate folder in infrastructure-live-multi-account-acme for your sandbox environment.

1. Run `terragrunt plan` to see what impact your changes will have.

1. If the plan looks good, run `terragrunt apply` to deploy those changes. 

Note: if you've made changes in infrastructure-modules-multi-account-acme, use the `--terragrunt-source` parameter to point
Terragrunt at your local checkout of infrastructure-modules-multi-account-acme. E.g., if you checked out 
infrastructure-modules-multi-account-acme to `~/source/infrastructure-modules-multi-account-acme`, then you can test your changes
locally, without creating a new release of infrastructure-modules-multi-account-acme, by running
`terragrunt plan --terragrunt-source ~/source/infrastructure-modules-multi-account-acme/my-module` and
`terragrunt apply --terragrunt-source ~/source/infrastructure-modules-multi-account-acme/my-module`.

Note: you can also create *automated* tests for your modules using the 
[Terratest](https://github.com/maxar-infrastructure/terratest) library. Check out the `test` folder in any Gruntwork module
for examples, such as the [module-ecs tests](https://github.com/maxar-infrastructure/module-ecs/tree/master/test) and 
[module-asg tests](https://github.com/maxar-infrastructure/module-asg/tree/master/test).


### Submit a pull request

Once your code is working in the sandbox environment:

* Commit your changes to a new branch

* Submit a pull request so other team members can review your code.

* If you only made changes in the sandbox environment in infrastructure-live-multi-account-acme, then your pull request 
  should include analogous changes in all the other environments in infrastructure-live-multi-account-acme (but, of course, 
  don't apply those changes yet!). 
  
* If you made changes in infrastructure-modules-multi-account-acme, then submit the pull request in that repo first. After
  that pull request has been merged and a new version released, you can submit a pull request (or multiple pull 
  requests) in infrastructure-live-multi-account-acme updating all environments to use the new version. All of this is 
  described in the next few sections.


### Merge in your changes

If the code looks good, merge your changes into the master branch. The basic idea is that master should always reflect
what's deployed in prod, so the next step is to deploy the code!


### Release a new version

If your code changes included a change to infrastructure-modules-multi-account-acme, you should release a new version by 
creating a new Git tag. If you use GitHub, you can do this by creating a new release on the releases page. 
Alternatively, you can do it with the Git CLI:

```bash
git tag -a v0.0.2 -m "added module foo"
git push --follow-tags
```


### Promote the new version to prod

You can now begin deploying this new, immutable version of your infrastructure through all of your environments:
e.g, qa -> stage -> prod. There are two ways to do this:
   
1. You can submit a single pull request in infrastructure-live-multi-account-acme to update all the environments. Once its
   merged, you can run `terragrunt plan` and `terragrunt apply` in each environment to deploy the changes.

1. If you need to test the changes in each environment before deploying to the next environment, you may want to do a
   separate pull request for each environment, and merge and deploy them one at a time.

As you deploy each environment, make sure to carefully check that the `plan` output matches what you expect!



## Next steps

Now that your code is built, tested, and deployed, it's time to take a look at [Monitoring, Alerting, and
Logging](07-monitoring-alerting-logging.md).
