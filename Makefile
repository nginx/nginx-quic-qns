#!/usr/bin/make

IMG = nginx-quic-qns
REG = public.ecr.aws/nginx
$(eval REPO=$(REG)/$(IMG))

default:
	@echo "valid targets: login build push all"

login:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(REG)

build:
	docker build --pull --no-cache -t $(IMG):latest -f Dockerfile .

push:
	docker tag $(IMG):latest $(REPO):latest
	docker push $(REPO):latest

all: login build push

.PHONY: all
