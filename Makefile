SHELL := /bin/sh
.ONESHELL:
.SHELLFLAGS: -euo
.DEFAULT_GOAL: help
.NOTPARALLEL:
.POSIX:

#

DOCKER ?= docker
PRECOMMIT ?= pre-commit
GIT ?= git

#

override DEVMACHINE_ROOT = $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

#

.PHONY: help
help:  ## Print this message
	@grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(DEVMACHINE_ROOT)/Makefile | sort | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#

.PHONY: init
init:  ## Initializes the workspace and installs all dependencies
	@cd $(DEVMACHINE_ROOT) && \
		$(PRECOMMIT) install --install-hooks --overwrite && \
		$(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg

.PHONY: pc
pc: ## Runs pre-commit over all files
	@cd $(DEVMACHINE_ROOT) && $(GIT) add . && $(PRECOMMIT) run --all-files

#

TAG ?= latest

.PHONY: docker
docker: ## Builds the Docker image
	$(DOCKER) build --compress $(DEVMACHINE_ROOT) --tag benvining/citrus_dev_machine:$(TAG)

.PHONY: deploy
deploy: docker ## Publishes the Docker image
	$(DOCKER) push benvining/citrus_dev_machine:$(TAG)
