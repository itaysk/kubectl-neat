
# TL;DR:
# make build: build locally
# make test: test all
# make test-X: test X
# make release: after git tag, release to github and prepare krew file

.PHONY: test test-unit test-component test-kubectl test-install build goreleaser release clean
os ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')

test: test-unit test-component test-kubectl test-install

test-unit:
	go test ./...

test-component: kubectl-neat_$(os)
	bats ./test/component.bats

test-kubectl: kubectl-neat_$(os)
	bats ./test/kubectl.bats

test-install: dist/kubectl-neat_$(os).tar.gz dist/checksums.txt
	bats ./test/install.bats

build: kubectl-neat_$(os)

SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
kubectl-neat_%: $(SRC)
	GOOS=$* go build -o $(@F)

# release by default will not publish. run with `publish=1` to publish
goreleaserflags = --skip-publish --snapshot
ifdef publish
	goreleaserflags =
endif
# relase always re-builds (no dependencies on purpose)
goreleaser:
	goreleaser --rm-dist $(goreleaserflags) 

dist/kubectl-neat_darwin.tar.gz dist/kubectl-neat_linux.tar.gz dist/checksums.txt: goreleaser
	# no op recipe
	@:

release: publish = 1
release: dist/kubectl-neat_darwin.tar.gz dist/kubectl-neat_linux.tar.gz dist/checksums.txt
	./krew-package.sh 'darwin' 'neat' './dist'
	./krew-package.sh 'linux' 'neat' './dist'
	# merge
	yq r --tojson "dist/kubectl-neat_darwin.yaml" > dist/darwin.json
	yq r --tojson "dist/kubectl-neat_linux.yaml" > dist/linux.json
	rm dist/kubectl-neat_darwin.yaml dist/kubectl-neat_linux.yaml
	jq --slurp '.[0].spec.platforms += .[1].spec.platforms | .[0]' 'dist/darwin.json' 'dist/linux.json' > 'dist/kubectl-neat.json'
	yq r  --prettyPrint dist/kubectl-neat.json > dist/kubectl-neat.yaml
	rm dist/kubectl-neat.json dist/darwin.json dist/linux.json

clean:
	rm -rf dist
	rm kubectl-neat*