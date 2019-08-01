#!/usr/bin/env bats

function setup() {
    runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    tmpdir=$(mktemp -d)
    # rename the plugin to avoid conflicts with existing installation
    plugin_name="neat2"
    plugin="$tmpdir"/kubectl-"$plugin_name"
    ln -s "$(pwd)/dist/$runtime_os/kubectl-neat" "$plugin"
    # PATH modification here has no external affect since bats runs in a subshell
    PATH="$PATH":"$tmpdir"
    kubectl delete -f ./test/fixtures/pod-1-neat.json 2>/dev/null || true
    kubectl create -f ./test/fixtures/pod-1-neat.json
}

function teardown() {
    kubectl delete -f ./test/fixtures/pod-1-neat.json 
    rm -rf "$tmpdir"
}

@test "plugin - json" {
    run kubectl "$plugin_name" pod myapp -o json
    [ "$status" -eq 0 ]
    jq --exit-status --argfile desired ./test/fixtures/pod-1-neat.json 'contains($desired)' <<<"$output"
}

@test "plugin - yaml" {
    run kubectl "$plugin_name" pod myapp -o yaml
    [ "$status" -eq 0 ]
    local outputjson=$(yq r --tojson -<<<"$output")
    jq --exit-status --argfile desired ./test/fixtures/pod-1-neat.json 'contains($desired)' <<<"$outputjson"
}
