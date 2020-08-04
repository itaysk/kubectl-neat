#!/usr/bin/env bats
load bats-workaround

function setup() {
    dir="dist"
    plugin="neat2"
    runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    ./krew-package.sh "$runtime_os" "$plugin" "$dir"
    kubectl krew install --manifest="$dir/kubectl-${plugin}_${runtime_os}.yaml" --archive="$dir/kubectl-neat_${runtime_os}.tar.gz"
}

function teardown() {
    kubectl krew remove "$plugin"
}

@test "krew install" {
    run2 kubectl "$plugin" get -- svc kubernetes -n default
    [ "$status" -eq 0 ]
    [ "${stdoutLines[1]}" = "kind: Service" ]
}