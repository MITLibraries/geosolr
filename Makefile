.PHONY: help dist publish promote
SHELL=/bin/bash
ECR_REGISTRY=672626379771.dkr.ecr.us-east-1.amazonaws.com
DATETIME:=$(shell date -u +%Y%m%dT%H%M%SZ)

help: ## Print this message
	@awk 'BEGIN { FS = ":.*##"; print "Usage:  make <target>\n\nTargets:" } \
		/^[-_[:alpha:]]+:.?*##/ { printf "  %-15s%s\n", $$1, $$2 }' $(MAKEFILE_LIST)

dist: ## Build docker image
	docker build -t $(ECR_REGISTRY)/geosolr-stage:latest \
		-t $(ECR_REGISTRY)/geosolr-stage:`git describe --always` \
		-t geosolr .

publish: ## Push and tag the latest image (use `make dist && make publish`)
	$$(aws ecr get-login --no-include-email --region us-east-1)
	docker push $(ECR_REGISTRY)/geosolr-stage:latest
	docker push $(ECR_REGISTRY)/geosolr-stage:`git describe --always`

promote: ## Promote the current staging build to production
	$$(aws ecr get-login --no-include-email --region us-east-1)
	docker pull $(ECR_REGISTRY)/geosolr-stage:latest
	docker tag $(ECR_REGISTRY)/geosolr-stage:latest $(ECR_REGISTRY)/geosolr-prod:latest
	docker tag $(ECR_REGISTRY)/geosolr-stage:latest $(ECR_REGISTRY)/geosolr-prod:$(DATETIME)
	docker push $(ECR_REGISTRY)/geosolr-prod:latest
	docker push $(ECR_REGISTRY)/geosolr-prod:$(DATETIME)
