
.PHONY: test test-unit test-component test-kubectl test-install build dist clean

test: test-unit test-component test-kubectl test-install

test-unit:
	bats ./test/unit.bats
	#kube-defaulter tests are in it's make file

test-component: dist
	bats ./test/component.bats

test-kubectl: dist
	bats ./test/kubectl.bats

test-install: dist
	bats ./test/install.bats

os ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
dist: dist/$(os)

dist/%: kube-defaulter/kube-defaulter_%
	mkdir -p dist/$*
	cp src/* dist/$*/
	cp kube-defaulter/kube-defaulter_$* dist/$*/kube-defaulter

build: kube-defaulter/kube-defaulter_$(os)

kube-defaulter/kube-defaulter_%:
	cd kube-defaulter && GOOS=$* go build -o $(@F)

clean:
	rm -rf ./dist ./krew
	rm kube-defaulter/kube-defaulter*

krew: dist/darwin dist/linux
	mkdir -p ./krew
	./krew-package.sh 'darwin' 'neat' 'krew'
	./krew-package.sh 'linux' 'neat' 'krew'

	# merge
	yq r --tojson "krew/kubectl-neat_darwin.yaml" > krew/darwin.json
	yq r --tojson "krew/kubectl-neat_linux.yaml" > krew/linux.json
	rm krew/kubectl-neat_darwin.yaml krew/kubectl-neat_linux.yaml
	jq --slurp '.[0].spec.platforms += .[1].spec.platforms | .[0]' 'krew/darwin.json' 'krew/linux.json' > 'krew/kubectl-neat.json'
	yq r krew/kubectl-neat.json > krew/kubectl-neat.yaml
	rm krew/kubectl-neat.json krew/darwin.json krew/linux.json