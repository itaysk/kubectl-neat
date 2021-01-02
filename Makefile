.PHONY: test test-e2e test-integration build goreleaser release clean
SRC := $(shell find . -type f -name '\*.go')
OS := $(if $(OS:Windows_NT=windows),windows,$(shell uname -s | tr '[:upper:]' '[:lower:]'))# on windows, OS is set by the system
BIN_OUT := dist/kubectl-neat
ARCHIVE_OUT := $(BIN_OUT)_$(OS)$(if $(findstring windows,$(OS)),.zip,.tar.gz)
test: $(SRC) $(shell find ./test/fixtures -type f)
	go test -v ./...

build: $(BIN_OUT)

test-e2e: $(BIN_OUT)
	PATH=$$PATH bats test/e2e-cli.bats #workaround PATH contains spaces in windows

test-integration: $(BIN_OUT)
	exe=$(abspath $(BIN_OUT)) bats ./test/e2e-kubectl.bats
	bats ./test/e2e-krew.bats

$(BIN_OUT): $(filter-out *_test.go,$(SRC))
	go build -o $(@)

# release by default will not publish. run with `publish=1` to publish
goreleaserflags = --skip-publish --snapshot
ifdef publish
	goreleaserflags =
endif
dist/kubectl-neat_darwin.tar.gz dist/kubectl-neat_linux.tar.gz dist/kubectl-neat_windows.zip dist/checksums.txt &: $(SRC) .goreleaser.yml
	goreleaser --rm-dist $(goreleaserflags) 

release: publish = 1
release: dist/kubectl-neat_darwin.tar.gz dist/kubectl-neat_linux.tar.gz dist/kubectl-neat_windows.zip dist/checksums.txt
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
