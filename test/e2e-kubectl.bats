#!/usr/bin/env bats
load bats-workaround

function setup() {
    tmpdir=$(mktemp -d)
    # rename the plugin to avoid conflicts with existing installation
    plugin_name="neat2"
    plugin="$tmpdir"/kubectl-"$plugin_name"
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