ifndef LOCATION
        $(error LOCATION is not set)
endif

ifndef TERRAGRUNT_IAM_ROLE
        $(error TERRAGRUNT_IAM_ROLE not set)
endif

.PHONY: all plan apply

all: plan

plan:
	export TERRAGRUNT_IAM_ROLE=$(TERRAGRUNT_IAM_ROLE) && \
	cd $(LOCATION) && \
	terragrunt  plan --terragrunt-non-interactive

apply:
	export TERRAGRUNT_IAM_ROLE=$(TERRAGRUNT_IAM_ROLE) && \
	cd $(LOCATION) && \
	terragrunt apply --terragrunt-non-interactive --auto-approve

destroy:
	export TERRAGRUNT_IAM_ROLE=$(TERRAGRUNT_IAM_ROLE) && \
	cd $(LOCATION) && \
	terragrunt destroy

