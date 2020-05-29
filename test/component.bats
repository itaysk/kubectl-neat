#!/usr/bin/env bats
runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]') 
exe="./kubectl-neat_${runtime_os}"

@test "pod - json" {
    run "$exe" <./test/fixtures/pod-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/pod-1-neat.json)
}

@test "service - json" {
    run "$exe" <./test/fixtures/service-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/service-1-neat.json)
}

@test "pv - json" {
    run "$exe" <./test/fixtures/pv-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/pv-1-neat.json)
}

@test "secret - json" {
    run "$exe" <./test/fixtures/secret-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/secret-1-neat.json)
}

@test "list - json" {
    run "$exe" <./test/fixtures/list-1-raw.json
    [ $status -eq 0 ]
    diff <(jq -S .<<<"$output") <(jq -S . ./test/fixtures/list-1-neat.json)
}

@test "pod - yaml" {
    run "$exe" <./test/fixtures/pod-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/pod-1-neat.json)
}

@test "service - yaml" {
    run "$exe" <./test/fixtures/service-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/service-1-neat.json)
}

@test "pv - yaml" {
    run "$exe" <./test/fixtures/pv-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/pv-1-neat.json)
}

@test "secret - yaml" {
    run "$exe" <./test/fixtures/secret-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/secret-1-neat.json)
}

@test "list - yaml" {
    run "$exe" <./test/fixtures/list-1-raw.yaml
    [ $status -eq 0 ]
    local ouputjson=$(yq r --tojson -<<<"$output")
    diff <(jq -S .<<<"$ouputjson") <(jq -S . ./test/fixtures/list-1-neat.json)
}