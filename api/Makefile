.DEFAULT_BUILD		:= default
SHELL  				:= bash
NAME 				:= hf-bench
REGISTRY 			:= docker.io
REPOSITORY 			:= xcid
TAG					:= latest

default: generate docker-build docker-push

.PHONY: init
init:
	pip3 install -r requirements.txt

.PHONY: generate
generate:
	python3 generate.py

.PHONY: docker-build
docker-build:
	cd output && docker build -t $(REGISTRY)/$(REPOSITORY)/$(NAME):$(TAG) .

.PHONY: docker-push
docker-push:
	docker push $(REGISTRY)/$(REPOSITORY)/$(NAME):$(TAG)

