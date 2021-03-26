#!/usr/bin/env bats
load bats-workaround

function setup() {
    runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    runtime_arch=$(go env GOARCH | tr '[:upper:]' '[:lower:]')
    tmpdir=$(mktemp -d)
    # rename the plugin to avoid conflicts with existing installation
    plugin_name="neat2"
    plugin="$tmpdir"/kubectl-"$plugin_name"
    exe="$PWD/$(find dist -path \*dist/kubectl-neat_${runtime_os}_${runtime_arch}\*/kubectl-neat)"
    ln -s "$exe" "$plugin"
    # PATH modification here has no external affect since bats runs in a subshell
    PATH="$PATH":"$tmpdir"
}

function teardown() {
    rm -rf "$tmpdir"
}

@test "plugin - json" {
    run2 kubectl "$plugin_name" get -o json -- svc kubernetes -n default
    [ "$status" -eq 0 ]
    [[ $stdout == "{"* ]]
}

@test "plugin - yaml" {
    run2 kubectl "$plugin_name" get -- svc kubernetes -n default
    [ "$status" -eq 0 ]
    [[ $stdout == "apiVersion"* ]]
}