.PHONY: help login build push

IMAGE_NAME := ghcr.io/twistingmercury/rust-tooling
# the Dockerfile FROM line is the source of truth, so the tag always matches the base
RUST_VERSION := $(shell sed -nE 's/^FROM rust:([0-9.]+)-slim.*/\1/p' Dockerfile)

default: help

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mAvailable targets:\033[0m\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

login: ## Log into ghcr.io
	echo $(GITHUB_GHRC_PAT) | docker login ghcr.io -u twistingmercury --password-stdin

build: ## Builds the docker image
	./build.sh

push: ## Push the image to ghcr.io/twistingmercury
	docker push $(IMAGE_NAME):rust$(RUST_VERSION)
	docker push $(IMAGE_NAME):latest
