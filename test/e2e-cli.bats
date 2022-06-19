#!/usr/bin/env bats
load bats-workaround
runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]')
runtime_arch=$(go env GOARCH | tr '[:upper:]' '[:lower:]')
exe="dist/kubectl-neat_${runtime_os}_${runtime_arch}"
rootDir="./test/fixtures"

@test "invalid args 1" {
    echo $exe >&3
    run2 "$exe" --foo
    [ $status -eq 1 ]
    [[ "$stderr" == "Error: unknown flag: --foo"* ]]
}

@test "invalid args 2" {
    run2 "$exe" get --foo
    [ $status -eq 1 ]
    [[ "$stderr" == "Error: Error invoking kubectl"* ]]
}

@test "invalid args 3" {
    run2 "$exe" foo
    [ $status -eq 1 ]
    [[ "$stderr" == 'Error: unknown command "foo" for "kubectl-neat"'* ]]
}

@test "local file" {
    run2 "$exe" -f - <"$rootDir/pod1-raw.yaml"
    [ $status -eq 0 ]
    [[ "$stdout" == "apiVersion"* ]]
}