SHELL := bash -exo pipefail

ifndef S3_STATE_BUCKET
$(error S3_STATE_BUCKET is undefined)
endif

ifndef TF_VAR_name
$(error TF_VAR_name is undefined)
endif

# TF options
TF_FLAGS ?= -input -no-color

# dry-run executes terraform plan without adding anything
.PHONY: dry-run
dry-run:
	$(MAKE) fix-s3-backend
	$(MAKE) terraform-init
	$(MAKE) terraform-plan

.PHONY: efs-provision
efs-provision:
	$(MAKE) fix-s3-backend
	$(MAKE) terraform-init
	$(MAKE) terraform-apply

.PHONY: efs-provision
efs-provision:
	$(MAKE) fix-s3-backend
	$(MAKE) terraform-init
	$(MAKE) terraform-destroy

# this is a workaround for bug https://github.com/hashicorp/terraform/issues/13589
.PHONY: fix-s3-backend
fix-s3-backend:
	mkdir -p $$HOME/.aws
	ln -sf /var/lib/telekube/aws-credentials $$HOME/.aws/credentials

.PHONY: terraform-init
terraform-init:
# init the config using s3 backend
	terraform init \
		-backend=true \
		-backend-config="bucket=$(S3_STATE_BUCKET)" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="key=$(TF_VAR_name)/efs.tfstate" \
		$(TF_FLAGS)

.PHONY: terraform-plan
terraform-plan:
	terraform plan \
		$(TF_FLAGS)

.PHONY: terraform-apply
terraform-apply:
	terraform apply \
		$(TF_FLAGS) \
		-auto-approve

.PHONY: terraform-destroy
terraform-destroy:
	terraform destroy --force \
		$(TF_FLAGS)
