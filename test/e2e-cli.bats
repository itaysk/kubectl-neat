#!/usr/bin/env bats
runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]') 
exe="./kubectl-neat_${runtime_os}"
rootDir="./test/fixtures"

@test "invalid args 1" {
    run "$exe" -foo
    [ $status -eq 1 ]
    [[ "$output" == "Error"* ]]
}

@test "invalid args 2" {
    run "$exe" get -foo
    [ $status -eq 1 ]
    [[ "$output" == "Error"* ]]
}

@test "invalid args 3" {
    run "$exe" foo
    [ $status -eq 1 ]
    [[ "$output" == "Error"* ]]
}

@test "local file" {
    run "$exe" -f - <"$rootDir/pod1-raw.yaml"
    [ $status -eq 0 ]
    [[ "$output" == "apiVersion"* ]]
}