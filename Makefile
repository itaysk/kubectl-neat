
# TL;DR:
# make build: build locally
# make test: run all tests
# make test-unit: just unit tests
# make test-e2e: just e2e tests
# make release: after git tag, release to github and prepare krew file

.PHONY: test test-unit test-e2e build goreleaser release clean
os ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
arch ?= $(shell go env GOARCH | tr '[:upper:]' '[:lower:]')
underscore = $(word $2,$(subst _, ,$1))

test: test-unit test-e2e test-integration

test-unit:
	go test -v ./...

test-e2e: dist/kubectl-neat_$(os)_$(arch)
	bats ./test/e2e-cli.bats

test-integration: dist/kubectl-neat_$(os)_$(arch).tar.gz dist/kubectl-neat_$(os)_$(arch)*/kubectl-neat dist/checksums.txt
	bats ./test/e2e-kubectl.bats
	bats ./test/e2e-krew.bats

build: dist/kubectl-neat_$(os)_$(arch)

SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
dist/kubectl-neat_%: $(SRC)
	GOOS=$(call underscore,$*,1) GOARCH=$(call underscore,$*,2) go build -o dist/$(@F)

# release by default will not publish. run with `publish=1` to publish
goreleaserflags = --skip-publish --snapshot
ifdef publish
	goreleaserflags =
endif
# relase always re-builds (no dependencies on purpose)
goreleaser: $(SRC)
	goreleaser --rm-dist $(goreleaserflags) 

dist/kubectl-neat_darwin_arm64.tar.gz dist/kubectl-neat_darwin_amd64.tar.gz dist/kubectl-neat_linux_arm64.tar.gz dist/kubectl-neat_linux_amd64.tar.gz dist/checksums.txt: goreleaser
	# no op recipe
	@:

release: publish = 1
release: dist/kubectl-neat_darwin_arm64.tar.gz dist/kubectl-neat_darwin_amd64.tar.gz dist/kubectl-neat_linux_arm64.tar.gz dist/kubectl-neat_linux_amd64.tar.gz dist/checksums.txt
	./krew-package.sh 'darwin' 'arm64' 'neat' './dist'
	./krew-package.sh 'darwin' 'amd64' 'neat' './dist'
	./krew-package.sh 'linux' 'arm64' 'neat' './dist'
	./krew-package.sh 'linux' 'amd64' 'neat' './dist'
	# merge
	yq r --tojson "dist/kubectl-neat_darwin_amd64.yaml" > dist/darwin-amd64.json
	yq r --tojson "dist/kubectl-neat_darwin_arm64.yaml" > dist/darwin-arm64.json
	yq r --tojson "dist/kubectl-neat_linux_amd64.yaml" > dist/linux-amd64.json
	yq r --tojson "dist/kubectl-neat_linux_arm64.yaml" > dist/linux-arm64.json

	rm dist/kubectl-neat_darwin_arm64.yaml dist/kubectl-neat_darwin_amd64.yaml dist/kubectl-neat_linux_arm64.yaml dist/kubectl-neat_linux_amd64.yaml
	jq --slurp '.[0].spec.platforms += .[1].spec.platforms | .[0]' 'dist/darwin-amd64.json' 'dist/darwin-arm64.json' > 'dist/darwin.json'
	jq --slurp '.[0].spec.platforms += .[1].spec.platforms | .[0]' 'dist/linux-amd64.json' 'dist/linux-arm64.json' > 'dist/linux.json'
	jq --slurp '.[0].spec.platforms += .[1].spec.platforms | .[0]' 'dist/linux.json' 'dist/darwin.json' > 'dist/kubectl-neat.json'
	yq r  --prettyPrint dist/kubectl-neat.json > dist/kubectl-neat.yaml
	rm dist/kubectl-neat.json dist/darwin.json dist/linux.json dist/darwin-amd64.json dist/darwin-arm64.json dist/linux-amd64.json dist/linux-arm64.json

clean:
	rm -rf dist
