
.PHONY: test test-unit test-component test-e2e-kubectl test-install build dist

test: test-unit test-component test-e2e-kubectl test-install

test-unit:
	bats ./test/unit.bats
	#kube-defaulter tests are in it's make file

test-component: dist
	bats ./test/component.bats

test-e2e-kubectl: dist
	bats ./test/e2e-kubectl.bats

test-install: dist
	bats ./test/install.bats

dist: build
	cp src/* dist/

build: dist/kube-defaulter

dist/kube-defaulter: kube-defaulter/kube-defaulter
	cp kube-defaulter/kube-defaulter dist/kube-defaulter

kube-defaulter/kube-defaulter:
	cd kube-defaulter && go build
	