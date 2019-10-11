
.PHONY: test test-unit test-component test-kubectl test-install build dist clean

test: test-unit test-component test-kubectl test-install

test-unit:
	go test ./...

test-component: dist
	bats ./test/component.bats

test-kubectl: dist
	bats ./test/kubectl.bats

test-install: dist
	bats ./test/install.bats

os ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
dist: dist/$(os)

dist/%: kubectl-neat_%
	mkdir -p dist/$*
	cp kubectl-neat_$* dist/$*/kubectl-neat

build: kubectl-neat_$(os)

SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
kubectl-neat_%: $(SRC)
	GOOS=$* go build -o $(@F)

clean:
	rm -rf ./dist ./krew
	rm kubectl-neat*

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