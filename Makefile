#!/usr/bin/make

default:
	@echo "valid targets: build push"

build:
	docker build --pull --no-cache -t nginx/nginx-quic-qns:latest -f Dockerfile .

push:
	docker push nginx/nginx-quic-qns:latest

.PHONY: default build push
