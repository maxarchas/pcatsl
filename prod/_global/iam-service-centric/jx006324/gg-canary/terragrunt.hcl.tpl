terraform {
   source = "git::ssh://git@github.digitalglobe.com/dg-cloud-infrastructure/infrastructure-modules-01.git//security/iam-service-centric?ref=v1.1.1"
}

include {
  path = find_in_parent_folders()
}


inputs = {
  # Jenkins account number for trust
  shared_services_account_id = "${TPL_TERRAFORM_SHARED_SERVICES_ACCOUNT_ID}"
  # Service information including github org and repo/service name
  maxar_github_org        = "jx006324"
  maxar_service_name      = "gg-canary"
  maxar_acronym_name      = "ggic"
  # Allow enabling a targeted service policy in the backend module found at github.com/maxar-infrastructure/module-sciac.git
  # The targeted policy files reside in modules-service-centric/iam-service-centric/policies/<git_org>/<service_name>-targeted-policy.json.tpl
  enable_targeted_policy  = false
  # Add the vpc_name for this account.  Necessary due to vpc_name not accessible in _globals and
  # _globals is not region specific
  vpc_name                = "${TPL_TERRAFORM_ENV}"
}
