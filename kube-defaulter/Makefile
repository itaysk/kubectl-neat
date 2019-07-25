.PHONY: build test test-cli

build: kube-defaulter

kube-defaulter:
	go build

test: build
	go test

test-cli: build
	bats cli.bats