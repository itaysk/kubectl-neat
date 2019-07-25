#!/usr/bin/env bats

@test "get default" {
    resourcePayload='{
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
            "labels": {
                "name": "myapp"
            },
            "name": "myapp",
            "namespace": "default"
        },
        "spec": {
            "containers": [
                {
                    "image": "foo",
                    "name": "myapp"
                }
            ]
        }
    }'
    jsonPathToDefault='spec.containers.0.imagePullPolicy'
    expect='Always'
    run ./kube-defaulter --command get-default --path "$jsonPathToDefault"<<<"$resourcePayload"
    [ "$status" -eq 0 ]
    [ "$output" == "$expect" ]
}


@test "is default" {
    resourcePayload='{
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
            "labels": {
                "name": "myapp"
            },
            "name": "myapp",
            "namespace": "default"
        },
        "spec": {
            "containers": [
                {
                    "imagePullPolicy": "Always"
                    "image": "foo",
                    "name": "myapp"
                }
            ]
        }
    }'
    jsonPathToDefault='spec.containers.0.imagePullPolicy'
	expect='true'
    run ./kube-defaulter --command is-default --path "$jsonPathToDefault"<<<"$resourcePayload"
    [ "$status" -eq 0 ]
    [ "$output" == "$expect" ]
}

@test "missing path" {
    resourcePayload='{
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
            "labels": {
                "name": "myapp"
            },
            "name": "myapp",
            "namespace": "default"
        },
        "spec": {
            "containers": [
                {
                    "imagePullPolicy": "Always"
                    "image": "foo",
                    "name": "myapp"
                }
            ]
        }
    }'
	expect='true'
    run ./kube-defaulter --command is-default<<<"$resourcePayload"
    [ "$status" -eq 1 ]
}

@test "missing stdin" {
	expect='true'
    jsonPathToDefault='spec.containers.0.imagePullPolicy'
    run ./kube-defaulter --command is-default --path "$jsonPathToDefault"
    [ "$status" -eq 1 ]
}

@test "missing command" {
    resourcePayload='{
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
            "labels": {
                "name": "myapp"
            },
            "name": "myapp",
            "namespace": "default"
        },
        "spec": {
            "containers": [
                {
                    "imagePullPolicy": "Always"
                    "image": "foo",
                    "name": "myapp"
                }
            ]
        }
    }'
    jsonPathToDefault='spec.containers.0.imagePullPolicy'
	expect='true'
    run ./kube-defaulter --path "$jsonPathToDefault"<<<"$resourcePayload"
    [ "$status" -eq 1 ]
}