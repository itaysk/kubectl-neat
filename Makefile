
.PHONY: test test-unit test-component test-e2e-kubectl test-install build dist clean

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

os = $(shell uname -s | tr '[:upper:]' '[:lower:]')
dist: build
	mkdir -p dist
	cp src/* dist/		
	cp dependencies/$(os)/* dist/
	cp kube-defaulter/kube-defaulter dist/kube-defaulter

build: kube-defaulter/kube-defaulter

kube-defaulter/kube-defaulter:
	cd kube-defaulter && GOOS=$(os) go build

clean:
	rm -rf ./dist
	rm kube-defaulter/kube-defaulter