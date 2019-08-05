#!/usr/bin/env bats
runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]') 
exe="dist/$runtime_os/kubectl-neat"

@test "pod - json" {
    KUBECTL_OUTPUT=json run "$exe" <./test/fixtures/pod-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/pod-1-neat.json)
}

@test "service - json" {
    KUBECTL_OUTPUT=json run "$exe" <./test/fixtures/service-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/service-1-neat.json)
}

@test "pv - json" {
    KUBECTL_OUTPUT=json run "$exe" <./test/fixtures/pv-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/pv-1-neat.json)
}

@test "pod - yaml" {
    KUBECTL_OUTPUT=yaml run "$exe" <./test/fixtures/pod-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/pod-1-neat.json)
}

@test "service - yaml" {
    KUBECTL_OUTPUT=yaml run "$exe" <./test/fixtures/service-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/service-1-neat.json)
}

@test "pv - yaml" {
    KUBECTL_OUTPUT=yaml run "$exe" <./test/fixtures/pv-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/pv-1-neat.json)
}

@test "missing dependency" {
    backup=$(which jq)
    sudo mv "$backup" "${backup}_"
    run "$exe"
    sudo mv "${backup}_" "$backup"
    [ "$status" -eq 1 ]
    [ "$output" = "at least one dependency is missing" ]
}