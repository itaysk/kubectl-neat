
# TL;DR:
# make build: build locally
# make test: run all tests
# make test-unit: just unit tests
# make test-e2e: just e2e tests
# make release: after git tag, release to github and prepare krew file

.PHONY: test test-unit test-e2e build goreleaser release clean
os ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')

test: test-unit test-component test-kubectl test-krew

test-unit:
	go test -v ./...

test-e2e: dirst/kubectl-neat_$(os) dist/kubectl-neat_$(os).tar.gz dist/checksums.txt
	bats ./test/e2e-cli.bats
	bats ./test/e2e-kubectl.bats
	bats ./test/e2e-krew.bats

build: dist/kubectl-neat_$(os)

SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
dist/kubectl-neat_%: $(SRC)
	GOOS=$* go build -o dist/$(@F)

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
