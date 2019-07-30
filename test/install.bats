#!/usr/bin/env bats

@test "krew install" {
    dir=$(mktemp -d)
    plugin="neat2"
    ./krew-package.sh $(uname -s) "$plugin" "$dir"
    kubectl krew install --manifest="$dir"/"$plugin".yaml --archive="$dir"/kubectl-neat.tar.gz

    run kubectl "$plugin" svc kubernetes

    kubectl krew remove "$plugin"
    rm -rf "$dir"
    [ "$status"  -eq 0 ]
    # just making sure it's the output for the service, not trying to check for correctness
    [ "${lines[1]}" = "kind: Service" ]
}