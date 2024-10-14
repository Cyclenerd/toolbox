# A Makefile helper file. This is just to make life easier...

.PHONY: init
init:
	terraform init -reconfigure

.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: lint
lint:
	terraform fmt -recursive -check -diff

.PHONY: validate
validate:
	terraform validate

.PHONY: show
show:
	terraform show

.PHONY: p
p: plan
.PHONY: plan
plan:
	terraform plan

.PHONY: apply
apply:
	terraform apply

.DEFAULT_GOAL := plan
