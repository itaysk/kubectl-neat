#!/usr/bin/env bats

function setup() {
    runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    tmpdir=$(mktemp -d)
    # rename the plugin to avoid conflicts with existing installation
    plugin_name="neat2"
    plugin="$tmpdir"/kubectl-"$plugin_name"
    ln -s "$(pwd)/kubectl-neat_${runtime_os}" "$plugin"
    # PATH modification here has no external affect since bats runs in a subshell
    PATH="$PATH":"$tmpdir"
}

function teardown() {
    rm -rf "$tmpdir"
}

@test "plugin - json" {
    run kubectl "$plugin_name" get svc kubernetes -o json
    [ "$status" -eq 0 ]
    [[ $output == "{"* ]]
}

@test "plugin - yaml" {
    run kubectl "$plugin_name" get svc kubernetes -o yaml
    [ "$status" -eq 0 ]
    [[ $output == "apiVersion"* ]]
}